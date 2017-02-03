%define _package __package__
%define _packagename __packagename__
%define _version __version__
%define _release __release__
%define _prefix  __prefix__
%define _sources_dir __sources_dir__
%define _tmppath /tmp
%define _packagedir __packagedir__
%define _os __os__
%define _platform __platform__
%define _project __project__
%define _author __author__
%define _summary __summary__
%define _url __url__
#%define _buildarch __buildarch__
#%define _includedirs __includedirs__

#
# SWATCH Specfile template
#
Name: %{_packagename} 
Version: %{_version} 
Release: %{_release} 
Packager: %{_author}
Summary: %{_summary}
License: BSD License
Group: CACTUS
Source: %{_source}
URL: %{_url} 
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot 
Prefix: %{_prefix}

# Dependencies
BuildRequires: __build_requires__
Requires: __requires__


%description
__description__

%prep

%build

%install 
# copy files to RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_prefix}/{bin,lib,include,etc}

if [ -d %{_packagedir}/bin ]; then
  cd %{_packagedir}/bin; \
  find . -name "*"  -exec install -D -m 755 {} $RPM_BUILD_ROOT/%{_prefix}/bin/%{_project}/{} \;
fi

if [ -d %{_packagedir}/scripts ]; then
  cd %{_packagedir}/scripts; \
  find . -name ".svn" -prune -o -name "*" -exec install -D -m 755 {} $RPM_BUILD_ROOT/%{_prefix}/bin/%{_project}/{} \;
fi

if [ -d %{_packagedir}/include ]; then
  cd %{_packagedir}/include; \
  find . \( -name "*.hpp"  -o -name "*.hxx" \)  -exec install -D -m 644 {} $RPM_BUILD_ROOT/%{_prefix}/include/{} \;
fi

if [ -d %{_packagedir}/lib ]; then
  cd %{_packagedir}/lib; \
  find . -name ".svn" -prune -o -name "*" -exec install -D -m 644 {} $RPM_BUILD_ROOT/%{_prefix}/lib/{} \;
fi

if [ -d %{_packagedir}/etc ]; then
  cd %{_packagedir}/etc; \
  find . -name ".svn" -prune -o -name "*" -exec install -D -m 644 {} $RPM_BUILD_ROOT/%{_prefix}/etc/{} \;
fi

#cp -rp %{_sources_dir}/* $RPM_BUILD_ROOT%{_prefix}/.


%clean 

%post 

%postun 

%files 
%defattr(-, root, root) 
%{_prefix}/bin
%{_prefix}/lib
%{_prefix}/etc
%{_prefix}/include

