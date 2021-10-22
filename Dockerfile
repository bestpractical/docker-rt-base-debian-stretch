FROM debian:buster-slim

LABEL maintainer="Best Practical Solutions <contact@bestpractical.com>"

ARG CPANFILE=https://raw.githubusercontent.com/bestpractical/rt/stable/etc/cpanfile
ARG CPM=https://git.io/cpm
ARG PERL_VERSION=5.32.1
ARG PERL_CONFIGURE="-des"
ARG PERL_PREFIX="/opt/perl-$PERL_VERSION"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Packages required for building Perl and modules
    build-essential \
    autoconf \
    # curl needs CA certificates to verify the authenticity of downloads.
    ca-certificates \
    curl \
    # The Perl getaddrinfo tests rely on /etc/services, provided by netbase.
    netbase \
    # RT core dependencies
    libgumbo1 \
    libmariadb-dev \
    libmariadb-dev-compat \
    libpq-dev \
    # RT optional dependencies
    apache2 \
    libapache2-mod-fcgid \
    gnupg \
    graphviz \
    w3m \
    libexpat-dev \
    libgd-dev \
    libssl-dev \
    libz-dev \
&& rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/src \
 && curl --fail --location "https://www.cpan.org/src/5.0/perl-$PERL_VERSION.tar.gz" \
  | tar -xz \
 && cd "perl-$PERL_VERSION" \
 # termios.t tests that tcdrain, tcflow, tcflush, and tcsendbreak all return
 # ENOTTY on a regular file.
 # The underlying ioctls are not implemented on podman
 # (probably runc/libcontainer) and return ENOSYS instead.
 # This sed simply deletes those tests as a hacky workaround for now,
 # since returning ENOSYS is legitimate.
 && sed -i '/^is(tc/ , /^$/ d' ext/POSIX/t/termios.t \
 && ./Configure -Dprefix="$PERL_PREFIX" $PERL_CONFIGURE \
 # The Net::Ping tests assume they can construct arbitrary packets when $< is 0.
 # This assumption is false when tests are running in a user namespace
 # (e.g., podman) or otherwise without the CAP_NET_RAW capability.
 # Run tests as nobody to force $< to be nonzero.
 && chown -R nobody: . \
 # The command: su -s /bin/sh -c "…" nobody
 # is just the sudo-less version of: sudo -u nobody …
 && su -s /bin/sh -c "make test" nobody \
 && make install \
 && cd /opt \
 && ln -s "$PERL_PREFIX" perl \
 && rm -rf "/usr/local/src/perl-$PERL_VERSION"

ENV PATH="/opt/perl/bin:$PATH"

RUN curl --fail --location --compressed -o /opt/perl/bin/cpm "$CPM" \
 && chmod a+rx /opt/perl/bin/cpm

RUN cd /tmp \
 && curl --fail --location --compressed -o cpanfile "$CPANFILE" \
 # 1. Find all the features named in RT's cpanfile.
 # 2. Filter out the ones named in the regexp test against $2.
 # 3. Print corresponding `--feature=name` options for cpm.
 # 4. Run cpm with those options, along with a baseline set,
 #    to test and install all dependencies needed to run RT's tests.
 && awk '($1 == "feature" && $2 !~ /(modperl1|oracle)/) { print "--feature=" substr($2, 2, length($2) - 2) }' cpanfile \
  | xargs -d\\n --exit --verbose cpm install --global --no-prebuilt --test --with-all \
 && rm -rf cpanfile ~/.perl-cpm

CMD cpan -a </dev/null >/dev/null && cat ~/.cpan/Bundle/Snapshot_*.pm
