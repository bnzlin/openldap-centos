FROM centos:6

RUN yum install -y yum-utils rpm-build tar

COPY ltb-project.repo /etc/yum.repos.d/
COPY RPM-GPG-KEY-LTB-project /etc/pki/rpm-gpg/
RUN yum-builddep -y openldap-ltb openldap-ltb-contrib-overlays

RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
WORKDIR /root/rpmbuild/
ENV OPENLDAP_VERSION=2.4.44
RUN yumdownloader --source openldap-ltb-$OPENLDAP_VERSION
RUN rpm -ivh  openldap-ltb-$OPENLDAP_VERSION*.el6.src.rpm
COPY accesslog_addConnectionInformation.patch SOURCES/
COPY openldap-ltb.spec SPECS/
ENV MAKEOPTS=-j4
RUN rpmbuild -ba SPECS/openldap-ltb.spec

RUN useradd ldap
RUN yum localinstall -y RPMS/x86_64/openldap-ltb-$OPENLDAP_VERSION*rpm RPMS/x86_64/openldap-ltb-contrib-overlays-$OPENLDAP_VERSION*rpm

VOLUME /usr/local/openldap/etc/openldap/
VOLUME /usr/local/openldap/var/

COPY run.sh /
RUN chmod +x /run.sh
CMD /run.sh


#yum install openldap-ltb

COPY init_config.sh /
RUN chmod +x /init_config.sh


