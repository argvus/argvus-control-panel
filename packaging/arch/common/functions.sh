#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154

arch_normalize_source_tree() {
	local expected="${srcdir}/${pkgname}-${pkgver}"
	local -a roots=()
	while IFS= read -r -d '' root; do roots+=("$root"); done < <(find "$srcdir" -mindepth 1 -maxdepth 1 -type d -print0)
	if (( ${#roots[@]} != 1 )); then
		printf 'error: expected exactly one extracted source directory in %s\n' "$srcdir" >&2
		return 1
	fi
	if [[ "${roots[0]}" != "$expected" ]]; then
		[[ ! -e "$expected" ]] || { printf 'error: source destination already exists: %s\n' "$expected" >&2; return 1; }
		mv -- "${roots[0]}" "$expected"
	fi
}

arch_check_control_panel() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"
	test -f "${source_root}/src/usr/share/argvus/control-panel/config/quickshell/argvus-control-panel/shell.qml"
	for script in "${source_root}/src/usr/share/argvus/control-panel/sh/"*.sh; do
		test -x "$script"
		bash -n "$script"
	done
}

arch_package_control_panel() {
	local source_root="${srcdir}/${pkgname}-${pkgver}"
	install -dm755 "${pkgdir}/usr/share/argvus/control-panel"
	cp -a "${source_root}/src/usr/share/argvus/control-panel/." "${pkgdir}/usr/share/argvus/control-panel/"
	find "${pkgdir}/usr/share/argvus/control-panel" -type f -name '*.sh' -exec chmod 755 {} +
	install -Dm644 "${source_root}/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
