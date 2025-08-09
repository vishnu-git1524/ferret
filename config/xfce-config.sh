#!/bin/bash
# Modern XFCE Desktop Configuration for Ferret OS
# Professional desktop environment with modern aesthetics

configure_modern_xfce() {
    local user_home="$1"
    local config_dir="$user_home/.config/xfce4"
    
    # Create configuration directories
    mkdir -p "$config_dir/xfconf/xfce-perchannel-xml"
    mkdir -p "$config_dir/desktop"
    mkdir -p "$config_dir/panel"
    mkdir -p "$config_dir/terminal"
    
    # Configure modern window manager (xfwm4)
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfwm4.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Arc-Dark"/>
    <property name="title_font" type="string" value="Inter Medium 9"/>
    <property name="button_layout" type="string" value="O|HMC"/>
    <property name="click_to_focus" type="bool" value="true"/>
    <property name="focus_delay" type="int" value="100"/>
    <property name="raise_delay" type="int" value="100"/>
    <property name="raise_on_focus" type="bool" value="false"/>
    <property name="raise_on_click" type="bool" value="true"/>
    <property name="mousewheel_rollup" type="bool" value="true"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="true"/>
    <property name="snap_width" type="int" value="15"/>
    <property name="wrap_windows" type="bool" value="true"/>
    <property name="wrap_workspaces" type="bool" value="false"/>
    <property name="double_click_time" type="int" value="300"/>
    <property name="double_click_distance" type="int" value="8"/>
    <property name="double_click_action" type="string" value="maximize"/>
    <property name="easy_click" type="string" value="Alt"/>
    <property name="box_move" type="bool" value="false"/>
    <property name="box_resize" type="bool" value="false"/>
    <property name="borderless_maximize" type="bool" value="true"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="prevent_focus_stealing" type="bool" value="true"/>
    <property name="urgent_blink" type="bool" value="true"/>
    <property name="workspace_count" type="int" value="4"/>
    <property name="workspace_names" type="array">
      <value type="string" value="Main"/>
      <value type="string" value="Work"/>
      <value type="string" value="Web"/>
      <value type="string" value="Media"/>
    </property>
    <property name="margin_top" type="int" value="0"/>
    <property name="margin_bottom" type="int" value="0"/>
    <property name="margin_left" type="int" value="0"/>
    <property name="margin_right" type="int" value="0"/>
  </property>
</channel>
EOF

    # Configure modern desktop (xfdesktop) with professional wallpaper
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="2"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.svg"/>
          <property name="color1" type="array">
            <value type="uint" value="11822"/>
            <value type="uint" value="13364"/>
            <value type="uint" value="17219"/>
            <value type="uint" value="65535"/>
          </property>
          <property name="color2" type="array">
            <value type="uint" value="5140"/>
            <value type="uint" value="6168"/>
            <value type="uint" value="8738"/>
            <value type="uint" value="65535"/>
          </property>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="2"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.svg"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="2"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.svg"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="2"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/ferret-wallpaper.svg"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-home" type="bool" value="false"/>
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-removable" type="bool" value="true"/>
      <property name="show-trash" type="bool" value="true"/>
    </property>
    <property name="icon-size" type="uint" value="40"/>
    <property name="show-tooltips" type="bool" value="true"/>
    <property name="single-click" type="bool" value="false"/>
  </property>
</channel>
EOF

    # Configure modern panel with Whisker Menu and professional layout
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfce4-panel.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <value type="int" value="2"/>
  </property>
  <property name="panel-1" type="empty">
    <property name="position" type="string" value="p=8;x=0;y=0"/>
    <property name="length" type="uint" value="100"/>
    <property name="position-locked" type="bool" value="true"/>
    <property name="size" type="uint" value="32"/>
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
      <value type="int" value="11"/>
    </property>
    <property name="background-style" type="uint" value="0"/>
    <property name="background-alpha" type="uint" value="90"/>
    <property name="enter-opacity" type="uint" value="100"/>
    <property name="leave-opacity" type="uint" value="90"/>
    <property name="mode" type="uint" value="0"/>
  </property>
  <property name="panel-2" type="empty">
    <property name="position" type="string" value="p=10;x=0;y=0"/>
    <property name="length" type="uint" value="100"/>
    <property name="position-locked" type="bool" value="true"/>
    <property name="size" type="uint" value="48"/>
    <property name="plugin-ids" type="array">
      <value type="int" value="12"/>
      <value type="int" value="13"/>
      <value type="int" value="14"/>
      <value type="int" value="15"/>
    </property>
    <property name="background-style" type="uint" value="0"/>
    <property name="background-alpha" type="uint" value="85"/>
    <property name="autohide-behavior" type="uint" value="1"/>
    <property name="mode" type="uint" value="0"/>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator"/>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="pulseaudio"/>
    <property name="plugin-6" type="string" value="power-manager-plugin"/>
    <property name="plugin-7" type="string" value="notification-plugin"/>
    <property name="plugin-8" type="string" value="separator"/>
    <property name="plugin-9" type="string" value="clock"/>
    <property name="plugin-10" type="string" value="separator"/>
    <property name="plugin-11" type="string" value="actions"/>
    <property name="plugin-12" type="string" value="showdesktop"/>
    <property name="plugin-13" type="string" value="launcher"/>
    <property name="plugin-14" type="string" value="launcher"/>
    <property name="plugin-15" type="string" value="launcher"/>
  </property>
</channel>
EOF

    # Configure modern settings with Arc Dark theme
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xsettings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Darker"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="DoubleClickTime" type="int" value="300"/>
    <property name="DoubleClickDistance" type="int" value="8"/>
    <property name="DndDragThreshold" type="int" value="8"/>
    <property name="CursorBlink" type="bool" value="true"/>
    <property name="CursorBlinkTime" type="int" value="1000"/>
    <property name="SoundThemeName" type="string" value="default"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
    <property name="EnableInputFeedbackSounds" type="bool" value="false"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="96"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="bool" value="false"/>
    <property name="ColorPalette" type="string" value="black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90"/>
    <property name="FontName" type="string" value="Inter 10"/>
    <property name="MonospaceFontName" type="string" value="JetBrains Mono 10"/>
    <property name="IconSizes" type="string" value="gtk-menu=16,16:gtk-button=16,16:gtk-small-toolbar=16,16:gtk-large-toolbar=24,24"/>
    <property name="KeyThemeName" type="string" value=""/>
    <property name="ToolbarStyle" type="string" value="icons"/>
    <property name="ToolbarIconSize" type="int" value="2"/>
    <property name="MenuImages" type="bool" value="true"/>
    <property name="ButtonImages" type="bool" value="false"/>
    <property name="MenuBarAccel" type="string" value="F10"/>
    <property name="CursorThemeName" type="string" value="Adwaita"/>
    <property name="CursorThemeSize" type="int" value="24"/>
    <property name="DecorationLayout" type="string" value="menu:minimize,maximize,close"/>
    <property name="TitlebarMiddleClick" type="string" value="lower"/>
    <property name="EnableAnimations" type="bool" value="true"/>
  </property>
</channel>
EOF

    # Configure modern keyboard shortcuts
    cat > "$config_dir/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="xfce4-terminal"/>
      <property name="&lt;Super&gt;r" type="string" value="xfce4-appfinder"/>
      <property name="&lt;Super&gt;f" type="string" value="thunar"/>
      <property name="&lt;Super&gt;w" type="string" value="firefox"/>
      <property name="&lt;Super&gt;e" type="string" value="code"/>
      <property name="Print" type="string" value="xfce4-screenshooter -f"/>
      <property name="&lt;Alt&gt;Print" type="string" value="xfce4-screenshooter -w"/>
      <property name="&lt;Shift&gt;Print" type="string" value="xfce4-screenshooter -r"/>
      <property name="&lt;Super&gt;l" type="string" value="xflock4"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="string" value="xfce4-session-logout"/>
    </property>
  </property>
  <property name="xfwm4" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Super&gt;Left" type="string" value="tile_left_key"/>
      <property name="&lt;Super&gt;Right" type="string" value="tile_right_key"/>
      <property name="&lt;Super&gt;Up" type="string" value="maximize_window_key"/>
      <property name="&lt;Super&gt;Down" type="string" value="hide_window_key"/>
      <property name="&lt;Alt&gt;F4" type="string" value="close_window_key"/>
      <property name="&lt;Alt&gt;F10" type="string" value="maximize_window_key"/>
      <property name="&lt;Alt&gt;F9" type="string" value="hide_window_key"/>
      <property name="&lt;Alt&gt;Tab" type="string" value="cycle_windows_key"/>
      <property name="&lt;Alt&gt;&lt;Shift&gt;Tab" type="string" value="cycle_reverse_windows_key"/>
    </property>
  </property>
</channel>
EOF

    # Configure modern terminal with professional appearance
    cat > "$config_dir/terminal/terminalrc" << 'EOF'
[Configuration]
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=TRUE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=100x30
MiscInheritGeometry=FALSE
MiscMenubarDefault=FALSE
MiscMouseAutohide=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToSelect=FALSE
MiscSlimTabs=TRUE
MiscNewTabAdjacent=FALSE
FontName=JetBrains Mono 11
BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
BackgroundDarkness=0.85
ColorForeground=#f8f8f2
ColorBackground=#282a36
ColorCursor=#f8f8f2
ColorBold=#f8f8f2
ColorBoldUseDefault=FALSE
ColorPalette=#21222c;#ff5555;#50fa7b;#f1fa8c;#bd93f9;#ff79c6;#8be9fd;#f8f8f2;#6272a4;#ff6e6e;#69ff94;#ffffa5;#d6acff;#ff92df;#a4ffff;#ffffff
EOF
}

# Apply configuration to system users
apply_system_xfce_config() {
    echo "Applying modern XFCE configuration..."
    
    # Apply to skeleton directory for new users
    configure_modern_xfce "/etc/skel"
    
    # Apply to existing ferret user
    if [[ -d "/home/ferret" ]]; then
        configure_modern_xfce "/home/ferret"
        chown -R ferret:ferret /home/ferret/.config
    fi
    
    # Set system-wide theme defaults
    cat > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Arc-Darker"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Inter 10"/>
    <property name="MonospaceFontName" type="string" value="JetBrains Mono 10"/>
  </property>
</channel>
EOF
}

# Install modern fonts and themes
install_modern_assets() {
    echo "Installing modern fonts and themes..."
    
    # Install Inter font
    mkdir -p /usr/share/fonts/truetype/inter
    cd /tmp
    wget -q https://github.com/rsms/inter/releases/download/v3.19/Inter-3.19.zip
    unzip -q Inter-3.19.zip
    cp Inter\ Desktop/*.ttf /usr/share/fonts/truetype/inter/
    
    # Install JetBrains Mono
    mkdir -p /usr/share/fonts/truetype/jetbrains-mono
    wget -q https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
    unzip -q JetBrainsMono-2.304.zip
    cp fonts/ttf/*.ttf /usr/share/fonts/truetype/jetbrains-mono/
    
    # Update font cache
    fc-cache -fv
    
    # Clean up
    rm -rf /tmp/Inter* /tmp/JetBrains* /tmp/fonts
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_modern_assets
    apply_system_xfce_config
    echo "Modern XFCE configuration applied successfully!"
fi
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
