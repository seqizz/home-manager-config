{pkgs, ... }:
{
  pulseaudio-toggle-hack = pkgs.writeScriptBin "pulseaudio-toggle-hack" ''
    for input in $(pactl list sources | grep ^Source | sed 's/.*#//'); do
      pactl set-source-mute $input toggle
    done
  '';
  psitool-script = pkgs.writeScriptBin "psitool-script" ''
    #!/usr/bin/env python3

    from hashlib import sha256
    from pickle import load, dump
    from socket import gethostname
    from time import time


    def current_psi_dict():
        with open('/proc/pressure/cpu', 'r') as psifile:
            total = psifile.read().split(' ')[4].split('=')[1]
            return {
                'value': int(total),
                'time': int(time())
            }


    def write_current_value(temp_file):
        current_value = current_psi_dict()
        with open(temp_file, 'wb') as valuefile:
            dump(current_value, valuefile)


    def get_last_value(name):
        result = False
        with open(name, 'rb') as valuefile:
            result = load(valuefile)

        return result


    def get_filename():
        hash = sha256(gethostname().encode('utf-8')).hexdigest()[:8]
        return '/tmp/{}_psi'.format(hash)


    def get_difference(temp_file):
        last_value = get_last_value(temp_file)
        if last_value is False:
            return "-1"
        current_value = current_psi_dict()
        time_difference = current_value['time'] - last_value['time']
        value_difference = current_value['value'] - last_value['value']
        if time_difference == 0:
            # Prevent division by zero, feed last one
            return current_value['value']
        return(int(value_difference / time_difference))


    def main():

        temp_file = get_filename()

        try:
            with open(temp_file) as f:
                print(get_difference(temp_file))
        except IOError:
            print('-1')
        finally:
            write_current_value(temp_file)


    main()

  '';

  git-cleanmerged = pkgs.writeScriptBin "git-cleanmerged" ''
    #!/usr/bin/env bash
    git fetch --all && for branch in $(git branch -l | grep -v master); do git branch -d $branch ; done
  '';

  innovpn-toggle = pkgs.writeScriptBin "innovpn-toggle" ''
    #!/usr/bin/env bash
    if [[ $(nmcli con show --active | grep tun0) ]]; then
        echo Active, deactivating
        nmcli con down VPN-aw
    else
        echo Not active, activating
        nmcli con up VPN-aw
    fi
  '';

  tarsnap-dotfiles = pkgs.writeScriptBin "tarsnap-dotfiles" ''
    #!/usr/bin/env bash
    tarsnap -c --keyfile $HOME/.tarsnap.key --cachedir $HOME/.tarsnapcache -f dotfiles-`date +%Y-%m-%d_%H-%M-%S` $HOME/syncfolder/dotfiles
  '';

  auto-rotate = pkgs.writeScriptBin "auto-rotate" ''
    #!/usr/bin/env bash
    # Auto rotate screen based on device orientation
    # Needs iio (monitor-sensor) and inotifytools

    LOG=/tmp/rotation_sensor.log
    export DISPLAY=:0

    # put your display name here
    DNAME=eDP-1

    # may change grep to match your touchscreen
    INDEV=$(${pkgs.xorg.xinput}/bin/xinput --list | ${pkgs.gnugrep}/bin/grep Finger | ${pkgs.gnused}/bin/sed 's/.*id=\([0-9]*\).*/\1/')


    function rotate {
        #echo ---- rotete ----
        ORIENTATION=$1
        CUR_ROT=$(${pkgs.xorg.xrandr}/bin/xrandr -q --verbose | ${pkgs.gnugrep}/bin/grep $DNAME | ${pkgs.coreutils}/bin/coreutils --coreutils-prog=cut -d" " -f6)

        NEW_ROT="normal"
        CTM="1 0 0 0 1 0 0 0 1"

        # Set the actions to be taken for each possible orientation
        case "$ORIENTATION" in
        normal)
            NEW_ROT="normal"
            CTM="1 0 0 0 1 0 0 0 1"
            # gsettings set com.canonical.Unity.Launcher launcher-position Top
            ;;
        bottom-up)
            NEW_ROT="inverted"
            CTM="-1 0 1 0 -1 1 0 0 1"
            # gsettings set com.canonical.Unity.Launcher launcher-position Top
            ;;
        right-up)
            CTM="0 1 0 -1 0 1 0 0 1"
            NEW_ROT="right"
            # gsettings set com.canonical.Unity.Launcher launcher-position Left
            ;;
        left-up)
            NEW_ROT="left"
            CTM="0 -1 1 1 0 0 0 0 1"
            # gsettings set com.canonical.Unity.Launcher launcher-position Left
            ;;
        esac


        # echo ORIENTATION: $ORIENTATION
        # echo INDEV:   $INDEV
        # echo DNAME:   $DNAME
        # echo DISPLAY: $DISPLAY
        # echo NEW_ROT: $NEW_ROT
        # echo CUR_ROT: $CUR_ROT
        # echo CTM:     $CTM
        if [ "$NEW_ROT" != "$CUR_ROT" ] ; then
            ${pkgs.xorg.xrandr}/bin/xrandr --output $DNAME --rotate $NEW_ROT
            ${pkgs.xorg.xinput}/bin/xinput set-prop $INDEV 'Coordinate Transformation Matrix' $CTM
        fi

    }

    # set default orientation
    # rotate left-up

    # kill old monitor-sensor if any
    killall monitor-sensor >> /dev/null 2>&1

    # Clear sensor.log at the beginning
    > $LOG

    # Launch monitor-sensor and store the output in a variable that can be parsed by the rest of the script
    ${pkgs.iio-sensor-proxy}/bin/monitor-sensor >> $LOG 2>&1 &

    # Parse output or monitor sensor to get the new orientation whenever the log file is updated
    # Possibles are: normal, bottom-up, right-up, left-up
    # Light data will be ignored
    while ${pkgs.inotify-tools}/bin/inotifywait -e modify $LOG; do
        # Read the last line that was added to the file and get the orientation
        ORIENTATION=$(${pkgs.gnugrep}/bin/grep 'orientation changed' $LOG | ${pkgs.coreutils}/bin/coreutils --coreutils-prog=tail -n 1 | ${pkgs.gawk}/bin/awk '{print $NF}')
        if [[ $ORIENTATION != "" ]] ; then
            rotate $ORIENTATION
            # then wipe the log again
            > $LOG
        fi
    done
  '';

  workman-toggle = pkgs.writeScriptBin "workman-toggle" ''
    #!/usr/bin/env ${pkgs.bash}/bin/bash

    current=$(setxkbmap -query | grep layout | awk '{print $2}')

    if [[ $1 == "query" ]]; then
      echo $current
    else
      if [ $current == 'tr' ];then
        setxkbmap workman-p-tr
      else
        setxkbmap tr
      fi
    fi
  '';

  xinput-toggle = pkgs.writeScriptBin "xinput-toggle" ''
    #!/usr/bin/env ${pkgs.bash}/bin/bash

    if [[ $1 == "query" ]]; then
      device=$2
      state=$(xinput list-props "$device" | grep "Device Enabled" | grep -o "[01]$")
      if [ $state == '1' ];then
        echo "on"
      else
        echo "off"
      fi
    else
      device=$1
      state=$(xinput list-props "$device" | grep "Device Enabled" | grep -o "[01]$")
      if [ $state == '1' ];then
        xinput --disable "$device"
      else
        xinput --enable "$device"
      fi
    fi
  '';

  lock-helper = pkgs.writeScriptBin "lock-helper" ''
    #!/usr/bin/env ${pkgs.bash}/bin/bash
    action=$1

    save_brightness () {
        ${pkgs.brightnessctl}/bin/brightnessctl g > /tmp/last_brightness
    }
    dim_screen () {
        DISPLAY=:0 ${pkgs.libnotify}/bin/notify-send -t 2000 "Zzzzz"
        ${pkgs.brightnessctl}/bin/brightnessctl s 20
    }

    restore_brightness () {
        ${pkgs.brightnessctl}/bin/brightnessctl s `${pkgs.coreutils}/bin/coreutils --coreutils-prog=cat /tmp/last_brightness`
    }

    lock_screen () {
        /run/wrappers/bin/sudo ${pkgs.slock}/bin/slock
    }

    if [[ "$action" == "start" ]]; then
        # Check if it's already locked and do nothing
        [[ `${pkgs.procps}/bin/pidof slock` ]] && return

        save_brightness
        dim_screen

    elif [[ "$action" == "cancel" ]]; then
        if test -f "/tmp/last_brightness"; then
            restore_brightness
        fi

    elif [[ "$action" == "lock" ]]; then
        lock_screen
    fi
  '';
}
