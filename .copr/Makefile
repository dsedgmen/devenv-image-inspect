# COPR make_srpm — bake Version/Release into shipped spec (.ONESHELL).
SHELL := /bin/bash
.ONESHELL:
.PHONY: srpm

srpm:
	set -euo pipefail
	dnf -y install git rpm-build rpmdevtools 2>/dev/null || \
	  yum -y install git rpm-build rpmdevtools 2>/dev/null || true
	chmod +x ./scripts/rpm-version.sh
	eval "$$(./scripts/rpm-version.sh --shell)"
	if [[ -z "$${VERSION}" || -z "$${RELEASE}" ]]; then
	  echo "rpm-version.sh produced empty VERSION/RELEASE" >&2
	  exit 1
	fi
	if [[ "$${RELEASE}" == "1" && "$${CHANNEL}" != "stable" ]]; then
	  echo "Refusing non-stable Release=1 (channel=$${CHANNEL})" >&2
	  exit 1
	fi
	echo "channel=$${CHANNEL} version=$${VERSION} release=$${RELEASE}"
	qmark='?'
	dist_suffix="%{$${qmark}dist}"
	SPEC_BUILT=/tmp/devenv-image-inspect-built.spec
	sed \
	  -e "s/^Version:.*/Version:        $${VERSION}/" \
	  -e "s/^Release:.*/Release:        $${RELEASE}$${dist_suffix}/" \
	  devenv-image-inspect.spec > "$${SPEC_BUILT}"
	grep -E '^(Version|Release):' "$${SPEC_BUILT}"
	mkdir -p "$(outdir)"
	rm -rf /tmp/devenv-image-inspect-pack
	mkdir -p "/tmp/devenv-image-inspect-pack/devenv-image-inspect-$${VERSION}"
	cp -a bin plugin autoload lua rpm README.md QUICKREF.txt LICENSE \
	  "/tmp/devenv-image-inspect-pack/devenv-image-inspect-$${VERSION}/"
	cp "$${SPEC_BUILT}" "/tmp/devenv-image-inspect-pack/devenv-image-inspect-$${VERSION}/devenv-image-inspect.spec"
	tar -C /tmp/devenv-image-inspect-pack -czf "/tmp/devenv-image-inspect-$${VERSION}.tar.gz" \
	  "devenv-image-inspect-$${VERSION}"
	rm -rf /tmp/devenv-image-inspect-rpmbuild
	mkdir -p /tmp/devenv-image-inspect-rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
	rpmbuild -bs "$${SPEC_BUILT}" \
	  --define "_topdir /tmp/devenv-image-inspect-rpmbuild" \
	  --define "_sourcedir /tmp" \
	  --define "_srcrpmdir $(outdir)"
	echo "Built SRPM channel=$${CHANNEL} $${VERSION}-$${RELEASE}"
	ls -la "$(outdir)"/devenv-image-inspect-*.src.rpm
