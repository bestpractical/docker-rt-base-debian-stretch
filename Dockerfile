FROM debian:stretch-slim

LABEL maintainer="Best Practical Solutions <contact@bestpractical.com>"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apache2 \
    cpanminus \
    curl \
    gcc \
    gnupg \
    vim \
    git \
    # RT core dependencies
    libapache2-mod-fcgid \
    libapache-session-perl \
    libbusiness-hours-perl \
    libc-dev \
    libcgi-emulate-psgi-perl \
    libcgi-psgi-perl \
    libconvert-color-perl \
    libcrypt-eksblowfish-perl \
    libcrypt-ssleay-perl \
    libcrypt-x509-perl \
    libcss-minifier-xs-perl \
    libcss-squish-perl \
    libdata-guid-perl \
    libdata-ical-perl \
    libdata-page-pageset-perl \
    libdata-page-perl \
    libdate-extract-perl \
    libdate-manip-perl \
    libdatetime-format-natural-perl \
    libdbd-sqlite3-perl \
    libdevel-globaldestruction-perl \
    libemail-address-list-perl \
    libemail-address-perl \
    libencode-perl \
    libfcgi-perl \
    libfcgi-procmanager-perl \
    libfile-sharedir-install-perl \
    libfile-sharedir-perl \
    libgd-graph-perl \
    libgraphviz-perl \
    libhtml-formattext-withlinks-andtables-perl \
    libhtml-formattext-withlinks-perl \
    libhtml-mason-perl  \
    libhtml-mason-psgihandler-perl \
    libhtml-quoted-perl \
    libhtml-rewriteattributes-perl \
    libhtml-scrubber-perl  \
    libipc-run3-perl \
    libipc-signal-perl \
    libjavascript-minifier-xs-perl \
    libjson-perl \
    liblocale-maketext-fuzzy-perl \
    liblocale-maketext-lexicon-perl \
    liblog-dispatch-perl \
    libmailtools-perl \
    libmime-tools-perl \
    libmime-types-perl \
    libmodule-refresh-perl \
    libmodule-signature-perl \
    libmodule-versions-report-perl \
    libnet-cidr-perl \
    libnet-ip-perl \
    libparallel-forkmanager-perl \
    libplack-perl \
    libregexp-common-net-cidr-perl \
    libregexp-common-perl \
    libregexp-ipv6-perl \
    librole-basic-perl \
    libscope-upper-perl \
    libserver-starter-perl \
    libsymbol-global-name-perl \
    libterm-readkey-perl  \
    libtext-password-pronounceable-perl \
    libtext-quoted-perl \
    libtext-template-perl \
    libtext-wikiformat-perl  \
    libtext-wrapper-perl \
    libtime-modules-perl \
    libtree-simple-perl  \
    libuniversal-require-perl \
    libxml-rss-perl \
    make \
    perl-doc \
    starlet \
    w3m \
    # RT developer dependencies
    libemail-abstract-perl \
    libfile-which-perl \
    liblocale-po-perl \
    liblog-dispatch-perl-perl \
    libmojolicious-perl \
    libperlio-eol-perl \
    libplack-middleware-test-stashwarnings-perl \
    libset-tiny-perl \
    libstring-shellquote-perl \
    libtest-deep-perl \
    libtest-email-perl \
    libtest-expect-perl \
    libtest-longstring-perl \
    libtest-mocktime-perl \
    libtest-nowarnings-perl \
    libtest-pod-perl \
    libtest-warn-perl \
    libtest-www-mechanize-perl \
    libtest-www-mechanize-psgi-perl \
    libwww-mechanize-perl \
    libxml-simple-perl \
    autoconf \
    libnet-ldap-server-test-perl \
    libencode-hanextra-perl \
    libgumbo1 \
    build-essential \
    libhtml-formatexternal-perl \
    libtext-worddiff-perl \
    libdbd-mysql-perl \
    libpq-dev \
&& rm -rf /var/lib/apt/lists/*

# Install from backports to get newer gpg
RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -t stretch-backports install -y --no-install-recommends \
    gnupg \
&& rm -rf /var/lib/apt/lists/*

RUN gpg --version

RUN cpanm \
  # RT dependencies
  # Install Module::Install first because after perl 5.26 "." fails to find
  # it in inc for older modules.
  Module::Install \
  Email::Address \
  Email::Address::List \
  Mozilla::CA \
  Encode::Detect::Detector \
  HTML::Gumbo \
  GnuPG::Interface \
  Module::Path \
  Moose \
  MooseX::NonMoose \
  MooseX::Role::Parameterized \
  Path::Dispatcher \
  Web::Machine \
  capitalization \
  DBIx::SearchBuilder \
  Parallel::ForkManager \
  # DBD::Pg version 3.15 fails tests when run as root. There is a merged fix
  # in github, but it is not yet released. Assuming it is released in 3.16,
  # it shouldn't be an issue after that. Until then, this can be installed
  # by passing --notest to cpanm for DBD::Pg.
  DBD::Pg \
  # RT extension development dependencies
  ExtUtils::MakeMaker \
&& rm -rf /root/.cpanm

CMD tail -f /dev/null
