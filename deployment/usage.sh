# =============================================================================
# usage.sh - 共通ヘルプ表示システム
# =============================================================================

#!/usr/bin/env bash

# usage.shの使用方法:
# 1. 各スクリプトでusage.shをsourceする
# 2. SCRIPT_DESCRIPTIONなどの変数を設定
# 3. show_usage関数を呼び出す

# -----------------------------------------------------------------------------
# 共通ヘルプ表示関数
# -----------------------------------------------------------------------------
function show_usage() {
    local script_name="${SCRIPT_NAME:-$(basename "${BASH_SOURCE[1]}")}"
    
    cat <<EOF
使い方: $(basename "$0")  [<オプション>...] ${USAGE_ARGS:-""}

パラメータファイル:
  デフォルト: ./parameters.sh
  環境変数 PARAMETERS_FILE で別のファイルを指定可能

    オプション:
      -h, --help		このヘルプを表示して終了

例:
  ./$(basename "$0")                    # デフォルトのparameters.shを使用
  PARAMETERS_FILE=./parameters_dev.sh ./$(basename "$0")  # 別のパラメータファイルを指定

終了コード:
  0  正常終了
  1  エラー（無効なオプション、パラメータファイル不存在等）
EOF
}

# -----------------------------------------------------------------------------
# 共通のコマンドライン引数処理
# -----------------------------------------------------------------------------
function process_common_args() {
    while [ -n "${1:-}" ]; do
        case "$1" in
            -h|--help) 
                show_usage
                exit 0
                ;;
            -*) 
                echo "エラー: 無効なオプション '$1' です。" >&2
                echo "使用可能なオプションについては「$(basename "${BASH_SOURCE[1]}") -h」を参照してください。" >&2
                exit 1
                ;;
            "") 
                break
                ;;
            *)
                # カスタム引数処理がある場合はここで処理
                if declare -f process_custom_args > /dev/null; then
                    if ! process_custom_args "$@"; then
                        echo "エラー: 不明な引数 '$1' です。" >&2
                        echo "使用可能なオプションについては「$(basename "${BASH_SOURCE[1]}") -h」を参照してください。" >&2
                        exit 1
                    fi
                    return $?
                else
                    echo "エラー: 不明な引数 '$1' です。" >&2
                    echo "使用可能なオプションについては「$(basename "${BASH_SOURCE[1]}") -h」を参照してください。" >&2
                    exit 1
                fi
                ;;
        esac
        shift
    done
}

# -----------------------------------------------------------------------------
# パラメータファイル読み込み処理
# -----------------------------------------------------------------------------
function load_parameters_file() {
    local parameters_file="${PARAMETERS_FILE:-${DEFAULT_PARAMETERS_FILE:-"./parameters.sh"}}"
    
    if [ ! -f "$parameters_file" ]; then
        echo "エラー: パラメータファイル '$parameters_file' が見つかりません。" >&2
        exit 1
    fi
    
    echo "パラメータファイルを読み込み中: $parameters_file"
    # shellcheck source=/dev/null
    . "$parameters_file"
}