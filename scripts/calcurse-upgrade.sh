#!/bin/sh

export TEXTDOMAIN='calcurse'

set -e

if [ "$1" = "--config" ]; then
  CONFFILE=$2
else
  CONFFILE=$HOME/.calcurse/conf
fi

if [ ! -e "$CONFFILE" ]; then
  echo "$(gettext "Configuration file not found:") $CONFFILE" >&2
  exit 1
fi

if grep -q -e '^auto_save=' -e '^auto_gc=' -e '^periodic_save=' \
  -e '^confirm_quit=' -e '^confirm_delete=' -e '^skip_system_dialogs=' \
  -e '^skip_progress_bar=' -e '^calendar_default_view=' \
  -e '^week_begins_on_monday=' -e '^color-theme=' -e '^layout=' \
  -e '^side-bar_width=' -e '^notify-bar_show=' -e '^notify-bar_date=' \
  -e '^notify-bar_clock=' -e '^notify-bar_warning=' -e '^notify-bar_command=' \
  -e '^notify-all=' -e '^output_datefmt=' -e '^input_datefmt=' \
  -e '^notify-daemon_enable=' -e '^notify-daemon_log=' "$CONFFILE"; then

  echo "$(gettext "Pre-3.0.0 configuration file format detected...")"

  tmpfile="${TMPDIR:-/tmp}/calcurse-upgrade.$!"
  [ -e "$tmpfile" ] && exit 1

  echo -n "$(gettext "Upgrade configuration directives...")"

  sed -e 's/^auto_save=/general.autosave=/' \
    -e 's/^auto_gc=/general.autogc=/' \
    -e 's/^periodic_save=/general.periodicsave=/' \
    -e 's/^confirm_quit=/general.confirmquit=/' \
    -e 's/^confirm_delete=/general.confirmdelete=/' \
    -e 's/^skip_system_dialogs=/general.systemdialogs=/' \
    -e 's/^skip_progress_bar=/general.progressbar=/' \
    -e 's/^calendar_default_view=/appearance.calendarview=/' \
    -e 's/^week_begins_on_monday=/general.firstdayofweek=/' \
    -e 's/^color-theme=/appearance.theme=/' \
    -e 's/^layout=/appearance.layout=/' \
    -e 's/^side-bar_width=/appearance.sidebarwidth=/' \
    -e 's/^notify-bar_show=/appearance.notifybar=/' \
    -e 's/^notify-bar_date=/format.notifydate=/' \
    -e 's/^notify-bar_clock=/format.notifytime=/' \
    -e 's/^notify-bar_warning=/notification.warning=/' \
    -e 's/^notify-bar_command=/notification.command=/' \
    -e 's/^notify-all=/notification.notifyall=/' \
    -e 's/^output_datefmt=/format.outputdate=/' \
    -e 's/^input_datefmt=/format.inputdate=/' \
    -e 's/^notify-daemon_enable=/daemon.enable=/' \
    -e 's/^notify-daemon_log=/daemon.log=/' "$CONFFILE" > "$tmpfile"
  mv "$tmpfile" "$CONFFILE"

  if grep -q -e '^[^#=][^#=]*$' -e '^[^#=][^#=]*#.*$' "$CONFFILE"; then
    sed '
      /^general.autosave=/{
        N
        s/\n//
      }
      /^general.autogc=/{
        N
        s/\n//
      }
      /^general.periodicsave=/{
        N
        s/\n//
      }
      /^general.confirmquit=/{
        N
        s/\n//
      }
      /^general.confirmdelete=/{
        N
        s/\n//
      }
      /^general.systemdialogs=/{
        N
        s/\n//
      }
      /^general.progressbar=/{
        N
        s/\n//
      }
      /^appearance.calendarview=/{
        N
        s/\n//
      }
      /^general.firstdayofweek=/{
        N
        s/\n//
      }
      /^appearance.theme=/{
        N
        s/\n//
      }
      /^appearance.layout=/{
        N
        s/\n//
      }
      /^appearance.sidebarwidth=/{
        N
        s/\n//
      }
      /^appearance.notifybar=/{
        N
        s/\n//
      }
      /^format.notifydate=/{
        N
        s/\n//
      }
      /^format.notifytime=/{
        N
        s/\n//
      }
      /^notification.warning=/{
        N
        s/\n//
      }
      /^notification.command=/{
        N
        s/\n//
      }
      /^notification.notifyall=/{
        N
        s/\n//
      }
      /^format.outputdate=/{
        N
        s/\n//
      }
      /^format.inputdate=/{
        N
        s/\n//
      }
      /^daemon.enable=/{
        N
        s/\n//
      }
      /^daemon.log=/{
        N
        s/\n//
      }' "$CONFFILE" > "$tmpfile"
    mv "$tmpfile" "$CONFFILE"
  fi

  awk '
  BEGIN { FS=OFS="=" }
  $1 == "general.systemdialogs" || $1 == "general.progressbar" \
    { $2 = ($2 == "yes") ? "no" : "yes" }
  $1 == "general.firstdayofweek" { $2 = ($2 == "yes") ? "monday" : "sunday" }
  $1 == "appearance.calendarview" { $2 = ($2 == 0) ? "monthly" : \
                                         ($2 == 1) ? "weekly"  : $2 }
  { print }
  ' < "$CONFFILE" > "$tmpfile"
  mv "$tmpfile" "$CONFFILE"

  echo -n ' '
  echo "$(gettext 'done')"
fi

