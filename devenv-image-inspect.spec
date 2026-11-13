# Macros (CI / COPR / rpmbuild --define):
#   devenv_fc_ver  — RPM Version
#   devenv_fc_rel  — RPM Release without dist (%%{?dist} appended)
Name:           devenv-image-inspect
Version:        %{?devenv_fc_ver}%{!?devenv_fc_ver:1.0.0}
Release:        %{?devenv_fc_rel}%{!?devenv_fc_rel:1}%{?dist}
Summary:        Browse/export container image metadata, history, filesystem

License:        MIT
URL:            https://github.com/dsedgmen/devenv-image-inspect
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  coreutils

Requires:       bash
Requires:       python3
Recommends:     podman

%description
CLI and shared sources to inspect local container images: metadata,
build history / recovered Dockerfile, filesystem browse, and full
export (meta.json, history, rootfs). Podman-first; docker fallback.

Install devenv-image-inspect-neovim and/or devenv-image-inspect-vim
for editor integration.

Versioning: main = beta; tags = stable/rc. See RELEASE.md.

%package -n devenv-image-inspect-neovim
Summary:        Neovim frontend for devenv-image-inspect
Requires:       %{name} = %{version}-%{release}
Requires:       neovim
Recommends:     podman

%description -n devenv-image-inspect-neovim
Loads image-inspect on the Neovim packpath and calls setup().

%package -n devenv-image-inspect-vim
Summary:        Vim frontend for devenv-image-inspect
Requires:       %{name} = %{version}-%{release}
Requires:       vim-enhanced
Recommends:     podman

%description -n devenv-image-inspect-vim
Loads image-inspect via vimfiles plugin (usr/share/vim/vimfiles/plugin/).

%prep
%autosetup -n %{name}-%{version}

%build
# no-op

%install
install -d %{buildroot}%{_bindir}
install -m 0755 bin/devenv-image-inspect %{buildroot}%{_bindir}/devenv-image-inspect

install -d %{buildroot}%{_datadir}/devenv-image-inspect/{bin,plugin,autoload,lua,rpm}
install -m 0755 bin/devenv-image-inspect %{buildroot}%{_datadir}/devenv-image-inspect/bin/devenv-image-inspect
install -m 0644 plugin/image-inspect.vim %{buildroot}%{_datadir}/devenv-image-inspect/plugin/image-inspect.vim
install -m 0644 autoload/image_inspect.vim %{buildroot}%{_datadir}/devenv-image-inspect/autoload/image_inspect.vim
install -m 0644 lua/image-inspect.lua %{buildroot}%{_datadir}/devenv-image-inspect/lua/image-inspect.lua
install -m 0644 README.md QUICKREF.txt %{buildroot}%{_datadir}/devenv-image-inspect/
install -m 0644 rpm/vim-plugin.vim rpm/neovim-plugin.lua %{buildroot}%{_datadir}/devenv-image-inspect/rpm/

# Neovim packpath
install -d %{buildroot}%{_datadir}/nvim/site/pack/devenv-image/start/devenv-image/{plugin,lua}
install -m 0644 lua/image-inspect.lua \
  %{buildroot}%{_datadir}/nvim/site/pack/devenv-image/start/devenv-image/lua/image-inspect.lua
install -m 0644 rpm/neovim-plugin.lua \
  %{buildroot}%{_datadir}/nvim/site/pack/devenv-image/start/devenv-image/plugin/devenv-image-inspect.lua

# Vim vimfiles
install -d %{buildroot}%{_datadir}/vim/vimfiles/plugin
install -d %{buildroot}%{_datadir}/vim/vimfiles/autoload
install -m 0644 rpm/vim-plugin.vim \
  %{buildroot}%{_datadir}/vim/vimfiles/plugin/devenv-image-inspect.vim
install -m 0644 autoload/image_inspect.vim \
  %{buildroot}%{_datadir}/vim/vimfiles/autoload/image_inspect.vim

%files
%license LICENSE
%doc README.md QUICKREF.txt
%{_bindir}/devenv-image-inspect
%dir %{_datadir}/devenv-image-inspect
%{_datadir}/devenv-image-inspect/

%files -n devenv-image-inspect-neovim
%{_datadir}/nvim/site/pack/devenv-image/

%files -n devenv-image-inspect-vim
%{_datadir}/vim/vimfiles/plugin/devenv-image-inspect.vim
%{_datadir}/vim/vimfiles/autoload/image_inspect.vim

%changelog
* Fri Nov 13 2026 David Sedgmen <dsedgmen@users.noreply.github.com> - 1.0.0-1
- Initial RPM: CLI + neovim/vim subpackages
