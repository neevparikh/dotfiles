if [ -d "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
# zerobrew
export ZEROBREW_DIR=/Users/neev/.zerobrew
export ZEROBREW_BIN=/Users/neev/.local/bin
export PKG_CONFIG_PATH="/opt/zerobrew/prefix/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
_zb_path_append() {
    local argpath="$1"
    case ":${PATH}:" in
        *:"$argpath":*) ;;
        *) export PATH="$argpath:$PATH" ;;
    esac;
}
_zb_path_append /opt/zerobrew/prefix/bin
