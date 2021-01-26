#!/bin/sh -e

# 用法:
#
# chmod 777 ./build-static-carthage
# ./build-static-carthage -d AFNetworking YYModel Masonry -p ios

XCCONFIG=""

# Platform
PLATFORM_NAME=""

# framework search path
FMWK_SEARCH_PATHS="\$(inherited) "
FMWK_SEARCH_PATHS+="./Carthage/Build/iOS/**"

# Dependencies
DEPENDENCIES=""

# Current flag cursor
CURRENT_FLAG=""

function ValidatePlatformName() {
    case "$1" in
    "ios" | "macos" | "tvos" | "watchos")
        echo "$1"
        ;;
    *)
        echo "$1"
        # 1代表脚本执行错误
        return 1
        ;;
    esac
}

function initConfig() {
    set -euo pipefail
    # mktemp /tmp下创建唯一的临时xcconfig
    XCCONFIG=$(mktemp /tmp/static.xcconfig.XXXXXX)

    # 清理临时xcconfig当 Interrupt, Hang Up, Terminate, Exit signals
    trap 'rm -f "$XCCONFIG"' INT TERM HUP EXIT

}

function chekcArgvs() {
    # 遍历参数数量 shift移除 -d YYImage YYKit YYModel -p ios  $# = 6
    while [ ! $# -eq 0 ]; do

        case "$1" in

        --platform | -p)

            CURRENT_FLAG="p"
            ;;

        --dependencies | -d)

            CURRENT_FLAG="d"
            ;;

        *)

            if [[ $CURRENT_FLAG == "p" ]]; then

                if [[ $PLATFORM_NAME == "" ]]; then

                    PLATFORM_NAME+=$(ValidatePlatformName $1)
                    # 如果返回1 代表platform无效
                    if [ $? -eq 1 ]; then
                        echo "'$PLATFORM_NAME' ==> 无效的Platform" >&2
                        exit $?
                    fi
                # 有值 只能指定单个platform
                else
                    echo "Platform参数过多，只能指定单个之一 ios、macos、watchos、tvos" >&2
                    exit 1
                fi

            elif [[ $CURRENT_FLAG == "d" ]]; then

                DEPENDENCIES+="$1 "

            else
                echo "'$1' 参数错误，请重新指定" >&2
                exit 1
            fi
            ;;
        esac
        shift
    done

    # check dependencies
    if [[ $DEPENDENCIES == "" ]]; then
        echo "请传入指定的依赖进行编译" >&2
        exit 1

    fi

    # check platform
    if [[ $PLATFORM_NAME == "" ]]; then
        echo "缺少指定平台参数" >&2
        exit 1

    fi
}

function writeConfig() {
    # 把以下属性写入临时的xcconfig文件进行临时依赖
    echo "MACH_O_TYPE = staticlib" >>$XCCONFIG

    echo "DEBUG_INFORMATION_FORMAT = dwarf" >>$XCCONFIG

    echo "FRAMEWORK_SEARCH_PATHS = $FMWK_SEARCH_PATHS" >>$XCCONFIG

    # For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
    # the build will fail on lipo due to duplicate architectures.
    # Xcode 12 Beta 3:
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A8169g = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    # Xcode 12 beta 4
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A8179i = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    # Xcode 12 beta 5
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A8189h = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    # Xcode 12 beta 6
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A8189n = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    # Xcode 12 GM (12A7208)
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A7208 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    # Xcode 12 GM (12A7209)
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A7209 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    # Xcode 12.0.1 GM (12A7300)
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12A7300 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig
    # Xcode 12.2 (12B45b)
    echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12B45b = arm64 arm64e armv7 armv7s armv6 armv8' >>$XCCONFIG
    # Xcode 12.3 (12C33)
    # echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_12C33 = arm64 arm64e armv7 armv7s armv6 armv8' >> $xcconfig

    echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200 = $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1200__BUILD_$(XCODE_PRODUCT_BUILD_VERSION))' >>$XCCONFIG

    echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >>$XCCONFIG

    echo 'ONLY_ACTIVE_ARCH=NO' >>$XCCONFIG

    echo 'VALID_ARCHS = $(inherited) x86_64' >>$XCCONFIG
}

function exportConfig() {
    # 导出XCODE_XCCONFIG_FILE 共享给其他shell使用
    export XCODE_XCCONFIG_FILE="$XCCONFIG"
}

function build() {
    echo
    echo "Building static frameworks with Xcode temporary xconfig file:"
    echo $XCCONFIG
    echo
    echo "With contents:"
    while read line; do
        echo "$line"
    done <$XCCONFIG
    echo
    echo "Building with command:"
    echo "carthage build --no-use-binaries --platform $PLATFORM_NAME $DEPENDENCIES"
    echo

    # Build Carthage
    carthage build --no-use-binaries --platform $PLATFORM_NAME $DEPENDENCIES
}

initConfig

chekcArgvs $@

writeConfig

exportConfig

build
