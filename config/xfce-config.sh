# XFCE Desktop Configuration for Ferret OS
# This script configures XFCE with Ferret OS branding and settings

configure_xfce_theme() {
    local config_dir="$1/config/xfce4"
    
    # Create configuration directories
    mkdir -p "$config_dir/xfconf/xfce-perchannel-xml"
    mkdir -p "$config_dir/desktop"
    mkdir -p "$config_dir/panel"
    
    # Configure window manager (xfwm4)
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfwm4.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Ferret-Blue"/>
    <property name="title_font" type="string" value="Inter Bold 10"/>
    <property name="button_layout" type="string" value="O|SHMC"/>
    <property name="click_to_focus" type="bool" value="true"/>
    <property name="focus_delay" type="int" value="250"/>
    <property name="raise_delay" type="int" value="250"/>
    <property name="raise_on_focus" type="bool" value="false"/>
    <property name="raise_on_click" type="bool" value="true"/>
    <property name="mousewheel_rollup" type="bool" value="true"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="false"/>
    <property name="snap_width" type="int" value="10"/>
    <property name="wrap_windows" type="bool" value="true"/>
    <property name="wrap_workspaces" type="bool" value="false"/>
    <property name="double_click_time" type="int" value="250"/>
    <property name="double_click_distance" type="int" value="5"/>
    <property name="double_click_action" type="string" value="maximize"/>
    <property name="easy_click" type="string" value="Alt"/>
    <property name="box_move" type="bool" value="false"/>
    <property name="box_resize" type="bool" value="false"/>
    <property name="borderless_maximize" type="bool" value="true"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="prevent_focus_stealing" type="bool" value="false"/>
    <property name="urgent_blink" type="bool" value="false"/>
    <property name="workspace_count" type="int" value="4"/>
    <property name="workspace_names" type="array">
      <value type="string" value="Workspace 1"/>
      <value type="string" value="Workspace 2"/>
      <value type="string" value="Workspace 3"/>
      <value type="string" value="Workspace 4"/>
    </property>
  </property>
</channel>
EOF

    # Configure desktop (xfdesktop)
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.png"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.png"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.png"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.png"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-home" type="bool" value="true"/>
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-removable" type="bool" value="true"/>
      <property name="show-trash" type="bool" value="true"/>
    </property>
    <property name="icon-size" type="uint" value="48"/>
    <property name="show-tooltips" type="bool" value="true"/>
  </property>
</channel>
EOF

    # Configure panel
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfce4-panel.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
        <value type="int" value="8"/>
        <value type="int" value="9"/>
        <value type="int" value="10"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu"/>
    <property name="plugin-2" type="string" value="separator"/>
    <property name="plugin-3" type="string" value="directorymenu"/>
    <property name="plugin-4" type="string" value="launcher"/>
    <property name="plugin-5" type="string" value="launcher"/>
    <property name="plugin-6" type="string" value="separator"/>
    <property name="plugin-7" type="string" value="tasklist"/>
    <property name="plugin-8" type="string" value="separator"/>
    <property name="plugin-9" type="string" value="systray"/>
    <property name="plugin-10" type="string" value="clock"/>
  </property>
</channel>
EOF

    # Configure session
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfce4-session.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="FailsafeSessionName" type="string" value="Failsafe"/>
    <property name="SessionName" type="string" value="Default"/>
    <property name="SaveOnExit" type="bool" value="true"/>
    <property name="PromptOnLogout" type="bool" value="true"/>
  </property>
  <property name="startup" type="empty">
    <property name="screensaver" type="empty">
      <property name="enabled" type="bool" value="true"/>
    </property>
  </property>
  <property name="splash" type="empty">
    <property name="Engine" type="string" value=""/>
  </property>
</channel>
EOF

    # Configure keyboard shortcuts
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Alt&gt;F1" type="string" value="xfce4-popup-applicationsmenu"/>
      <property name="&lt;Alt&gt;F2" type="string" value="xfce4-appfinder --collapsed"/>
      <property name="&lt;Alt&gt;F3" type="string" value="xfce4-appfinder"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="string" value="xflock4"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;l" type="string" value="xflock4"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="xfce4-terminal"/>
      <property name="&lt;Super&gt;p" type="string" value="xfce4-display-settings --minimal"/>
      <property name="&lt;Super&gt;r" type="string" value="xfce4-appfinder"/>
      <property name="Print" type="string" value="xfce4-screenshooter"/>
      <property name="&lt;Control&gt;&lt;Alt&gt;t" type="string" value="xfce4-terminal"/>
    </property>
  </property>
  <property name="xfwm4" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Alt&gt;Tab" type="string" value="cycle_windows_key"/>
      <property name="&lt;Alt&gt;&lt;Shift&gt;Tab" type="string" value="cycle_reverse_windows_key"/>
      <property name="&lt;Alt&gt;Delete" type="string" value="del_workspace_key"/>
      <property name="&lt;Alt&gt;F10" type="string" value="maximize_window_key"/>
      <property name="&lt;Alt&gt;F11" type="string" value="fullscreen_key"/>
      <property name="&lt;Alt&gt;F12" type="string" value="above_key"/>
      <property name="&lt;Alt&gt;F4" type="string" value="close_window_key"/>
      <property name="&lt;Alt&gt;F6" type="string" value="stick_window_key"/>
      <property name="&lt;Alt&gt;F7" type="string" value="move_window_key"/>
      <property name="&lt;Alt&gt;F8" type="string" value="resize_window_key"/>
      <property name="&lt;Alt&gt;F9" type="string" value="hide_window_key"/>
      <property name="&lt;Alt&gt;Insert" type="string" value="add_workspace_key"/>
      <property name="&lt;Alt&gt;space" type="string" value="popup_menu_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Down" type="string" value="down_workspace_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Left" type="string" value="left_workspace_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Right" type="string" value="right_workspace_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Up" type="string" value="up_workspace_key"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Left" type="string" value="move_window_left_key"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Right" type="string" value="move_window_right_key"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Up" type="string" value="move_window_up_key"/>
      <property name="&lt;Primary&gt;&lt;Shift&gt;&lt;Alt&gt;Down" type="string" value="move_window_down_key"/>
      <property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>
      <property name="Escape" type="string" value="cancel_key"/>
      <property name="Left" type="string" value="left_key"/>
      <property name="Right" type="string" value="right_key"/>
      <property name="Up" type="string" value="up_key"/>
      <property name="Down" type="string" value="down_key"/>
    </property>
  </property>
</channel>
EOF
}

# Function to create default desktop files
create_desktop_launchers() {
    local applications_dir="$1/applications"
    mkdir -p "$applications_dir"
    
    # Ferret OS Welcome application
    cat > "$applications_dir/ferret-welcome.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Welcome to Ferret OS
Name[es]=Bienvenido a Ferret OS
Name[fr]=Bienvenue sur Ferret OS
Comment=Get started with Ferret OS
Comment[es]=Comience con Ferret OS
Comment[fr]=Commencer avec Ferret OS
Exec=ferret-welcome
Icon=ferret-welcome
Terminal=false
Categories=System;
Keywords=welcome;first;setup;guide;
StartupNotify=true
EOF

    # System Monitor
    cat > "$applications_dir/ferret-monitor.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Ferret System Monitor
Comment=Monitor system resources and processes
Exec=xfce4-taskmanager
Icon=utilities-system-monitor
Terminal=false
Categories=System;Monitor;
Keywords=system;process;monitor;cpu;memory;
StartupNotify=true
EOF

    # Settings Manager
    cat > "$applications_dir/ferret-settings.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Ferret Settings
Comment=Configure your Ferret OS system
Exec=xfce4-settings-manager
Icon=preferences-system
Terminal=false
Categories=Settings;DesktopSettings;
Keywords=settings;preferences;configuration;
StartupNotify=true
EOF
}

# Export functions for use in build script
export -f configure_xfce_theme
export -f create_desktop_launchers
