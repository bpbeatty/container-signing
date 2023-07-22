FROM registry.fedoraproject.org/fedora:latest AS builder

RUN dnf install --disablerepo='*' --enablerepo='fedora,updates' --setopt install_weak_deps=0 --nodocs --assumeyes rpm-build systemd-rpm-macros

ADD files/usr/etc /tmp/bpbeatty/signing/usr/etc

RUN mkdir -p /tmp/bpbeatty/rpmbuild/SOURCES && \
  tar cf /tmp/bpbeatty/rpmbuild/SOURCES/bpbeatty-signing.tar.gz -C /tmp bpbeatty/signing

ADD rpmspec/*.spec /tmp/bpbeatty

RUN rpmbuild -ba \
    --define '_topdir /tmp/bpbeatty/rpmbuild' \
    --define '%_tmppath %{_topdir}/tmp' \
    /tmp/bpbeatty/*.spec

RUN mkdir /tmp/bpbeatty/{files,rpms}

# Dump a file list for each RPM for easier consumption
RUN \
    for RPM in /tmp/bpbeatty/rpmbuild/RPMS/*/*.rpm; do \
        NAME="$(rpm -q $RPM --queryformat='%{NAME}')"; \
        mkdir "/tmp/bpbeatty/files/${NAME}"; \
        rpm2cpio "${RPM}" | cpio -idmv --directory "/tmp/bpbeatty/files/${NAME}"; \
        cp "${RPM}" "/tmp/bpbeatty/rpms/$(rpm -q "${RPM}" --queryformat='%{NAME}.%{ARCH}.rpm')"; \
    done

FROM scratch

# Copy build RPMs
COPY --from=builder /tmp/bpbeatty/rpms /rpms
# Copy dumped RPM content
COPY --from=builder /tmp/bpbeatty/files /files
