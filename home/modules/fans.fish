# Motherboard fan speeds and CPU package temperature from hwmon.
# Needs the nct6775 module (boot.kernelModules on alex-pc); no root required.
function fans --description "Show motherboard fan RPMs and CPU package temperature"
    if contains -- -w $argv; or contains -- --watch $argv
        watch --interval 2 --no-title fish --command fans
        return
    end

    # hwmon numbering can change between boots, so find the chip by name.
    set -l chip (grep --files-with-matches --line-regexp 'nct[0-9]*' /sys/class/hwmon/hwmon*/name | string replace /name '')[1]
    if test -z "$chip"
        echo "fans: no nct67xx hwmon device found (is nct6775 loaded?)" >&2
        return 1
    end

    for f in $chip/fan*_input
        set -l n (string match --regex '\d+' (path basename $f))
        set -l duty -
        if test -r $chip/pwm$n
            set duty (math --scale 0 (cat $chip/pwm$n) \* 100 / 255)%
        end
        printf 'fan%s  %5d rpm  %4s\n' $n (cat $f) $duty
    end

    for l in /sys/class/hwmon/hwmon*/temp*_label
        if test (cat $l) = "Package id 0"
            printf 'cpu   %5.1f °C\n' (math (cat (string replace _label _input $l)) / 1000)
            break
        end
    end
end
