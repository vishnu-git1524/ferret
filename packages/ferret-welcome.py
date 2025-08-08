#!/usr/bin/env python3
"""
Ferret OS Welcome Application
A friendly welcome screen for new users with essential information and quick setup
"""

import tkinter as tk
from tkinter import ttk, messagebox, font
import subprocess
import webbrowser
import os
import sys
from pathlib import Path

class FerretWelcome:
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.create_widgets()
        
    def setup_window(self):
        """Configure the main window"""
        self.root.title("Welcome to Ferret OS")
        self.root.geometry("800x600")
        self.root.resizable(True, True)
        
        # Center the window
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() // 2) - (800 // 2)
        y = (self.root.winfo_screenheight() // 2) - (600 // 2)
        self.root.geometry(f"800x600+{x}+{y}")
        
        # Set icon if available
        icon_path = "/usr/share/pixmaps/ferret-icon.png"
        if os.path.exists(icon_path):
            try:
                self.root.iconphoto(True, tk.PhotoImage(file=icon_path))
            except:
                pass
        
        # Set theme colors
        self.root.configure(bg='#f8fafc')
        
    def create_widgets(self):
        """Create and layout all widgets"""
        # Main container
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        # Header section
        self.create_header(main_frame)
        
        # Content notebook
        self.create_notebook(main_frame)
        
        # Footer section
        self.create_footer(main_frame)
        
    def create_header(self, parent):
        """Create the header with logo and title"""
        header_frame = ttk.Frame(parent)
        header_frame.pack(fill=tk.X, pady=(0, 20))
        
        # Logo (if available)
        logo_path = "/usr/share/pixmaps/ferret-logo.png"
        if os.path.exists(logo_path):
            try:
                logo_image = tk.PhotoImage(file=logo_path)
                # Resize logo to reasonable size
                logo_image = logo_image.subsample(4, 4)  # Adjust as needed
                logo_label = ttk.Label(header_frame, image=logo_image)
                logo_label.image = logo_image  # Keep a reference
                logo_label.pack(side=tk.LEFT, padx=(0, 20))
            except:
                pass
        
        # Title and subtitle
        title_frame = ttk.Frame(header_frame)
        title_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        title_font = font.Font(family="Inter", size=24, weight="bold")
        title_label = ttk.Label(title_frame, text="Welcome to Ferret OS", font=title_font)
        title_label.pack(anchor=tk.W)
        
        subtitle_font = font.Font(family="Inter", size=12)
        subtitle_label = ttk.Label(title_frame, 
                                 text="Fast, Reliable, Modern Linux Distribution",
                                 font=subtitle_font)
        subtitle_label.pack(anchor=tk.W, pady=(5, 0))
        
    def create_notebook(self, parent):
        """Create the main content notebook"""
        self.notebook = ttk.Notebook(parent)
        self.notebook.pack(fill=tk.BOTH, expand=True, pady=(0, 20))
        
        # Welcome tab
        self.create_welcome_tab()
        
        # Getting Started tab
        self.create_getting_started_tab()
        
        # Features tab
        self.create_features_tab()
        
        # Support tab
        self.create_support_tab()
        
    def create_welcome_tab(self):
        """Create the welcome tab"""
        tab_frame = ttk.Frame(self.notebook)
        self.notebook.add(tab_frame, text="Welcome")
        
        # Scrollable content
        canvas = tk.Canvas(tab_frame, bg='#ffffff')
        scrollbar = ttk.Scrollbar(tab_frame, orient=tk.VERTICAL, command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)
        
        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        # Content
        content_frame = ttk.Frame(scrollable_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=30, pady=30)
        
        # Welcome message
        welcome_text = """
Welcome to Ferret OS!

Thank you for choosing Ferret OS, a modern Linux distribution designed for 
developers, professionals, and everyday users. Ferret OS combines the stability 
of Debian with a beautiful, user-friendly desktop environment.

Key highlights of your new system:

🖥️  XFCE Desktop Environment - Lightweight and customizable
📦  Multiple Package Formats - APT, Flatpak, and AppImage support
🔒  Enhanced Security - UFW firewall and AppArmor protection
🎨  Beautiful Design - Custom Ferret OS theme and branding
⚡  Performance Optimized - Fast boot times and responsive interface

Whether you're developing software, creating content, or simply browsing the web,
Ferret OS provides all the tools you need in a polished, reliable package.
        """
        
        text_widget = tk.Text(content_frame, wrap=tk.WORD, bg='#ffffff', 
                             font=('Inter', 11), height=15, relief=tk.FLAT)
        text_widget.insert(tk.END, welcome_text.strip())
        text_widget.configure(state=tk.DISABLED)
        text_widget.pack(fill=tk.BOTH, expand=True)
        
        # Pack canvas and scrollbar
        canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
    def create_getting_started_tab(self):
        """Create the getting started tab"""
        tab_frame = ttk.Frame(self.notebook)
        self.notebook.add(tab_frame, text="Getting Started")
        
        content_frame = ttk.Frame(tab_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=30, pady=30)
        
        # Quick actions section
        actions_label = ttk.Label(content_frame, text="Quick Actions", 
                                font=('Inter', 14, 'bold'))
        actions_label.pack(anchor=tk.W, pady=(0, 15))
        
        # Action buttons grid
        actions_frame = ttk.Frame(content_frame)
        actions_frame.pack(fill=tk.X, pady=(0, 30))
        
        # Configure grid weights
        for i in range(3):
            actions_frame.columnconfigure(i, weight=1)
        
        # Action buttons
        self.create_action_button(actions_frame, "🌐 Connect to Internet", 
                                "Open network settings", self.open_network_settings, 0, 0)
        self.create_action_button(actions_frame, "🔄 Update System", 
                                "Check for updates", self.update_system, 0, 1)
        self.create_action_button(actions_frame, "📱 Install Apps", 
                                "Browse app store", self.open_app_store, 0, 2)
        self.create_action_button(actions_frame, "⚙️ System Settings", 
                                "Configure your system", self.open_settings, 1, 0)
        self.create_action_button(actions_frame, "📁 File Manager", 
                                "Browse your files", self.open_file_manager, 1, 1)
        self.create_action_button(actions_frame, "💻 Terminal", 
                                "Open command line", self.open_terminal, 1, 2)
        
        # Tips section
        tips_label = ttk.Label(content_frame, text="Essential Tips", 
                             font=('Inter', 14, 'bold'))
        tips_label.pack(anchor=tk.W, pady=(0, 15))
        
        tips_text = """
• Use Super (Windows) key + R to open the application launcher
• Right-click on the desktop to access context menu and settings
• The panel at the bottom contains your applications, workspaces, and system tray
• Press Ctrl+Alt+T to open a terminal window
• Use the Software application to install new programs
• Right-click on the panel to customize it or add new items
• Access system settings through the Settings Manager
• Use workspaces (virtual desktops) to organize your applications
        """
        
        tips_widget = tk.Text(content_frame, wrap=tk.WORD, bg='#f8fafc', 
                            font=('Inter', 10), height=10, relief=tk.FLAT)
        tips_widget.insert(tk.END, tips_text.strip())
        tips_widget.configure(state=tk.DISABLED)
        tips_widget.pack(fill=tk.BOTH, expand=True)
        
    def create_action_button(self, parent, title, subtitle, command, row, col):
        """Create a styled action button"""
        button_frame = ttk.Frame(parent, relief=tk.RIDGE, borderwidth=1)
        button_frame.grid(row=row, column=col, padx=10, pady=10, sticky="nsew")
        
        button = ttk.Button(button_frame, text=title, command=command)
        button.pack(fill=tk.X, padx=10, pady=(10, 5))
        
        subtitle_label = ttk.Label(button_frame, text=subtitle, 
                                 font=('Inter', 9), foreground='#64748b')
        subtitle_label.pack(padx=10, pady=(0, 10))
        
    def create_features_tab(self):
        """Create the features tab"""
        tab_frame = ttk.Frame(self.notebook)
        self.notebook.add(tab_frame, text="Features")
        
        content_frame = ttk.Frame(tab_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=30, pady=30)
        
        features_text = """
DESKTOP ENVIRONMENT
• XFCE 4.18+ - Lightweight, fast, and highly customizable
• Beautiful Ferret OS theme with consistent design
• Multiple workspaces for better organization
• Customizable panels and desktop

APPLICATIONS
• Firefox - Fast and secure web browser
• LibreOffice - Full office suite for productivity
• GIMP - Professional image editing
• VLC - Universal media player
• VS Code - Advanced code editor (via Flatpak)
• Many more applications available in the app store

PACKAGE MANAGEMENT
• APT - Native Debian package management
• Flatpak - Sandboxed applications for security
• AppImage - Portable application format
• GNOME Software - Graphical app store
• Synaptic - Advanced package manager

SECURITY & PRIVACY
• UFW Firewall - Pre-configured for security
• AppArmor - Mandatory access control
• Automatic security updates
• LUKS disk encryption support
• Secure boot compatibility

DEVELOPMENT TOOLS
• Complete build toolchain (GCC, Make, CMake)
• Python 3.x with pip
• Node.js and npm
• Git version control
• Docker support (optional)
• Multiple text editors and IDEs

MULTIMEDIA
• Full codec support for audio and video
• PulseAudio for advanced audio management
• Hardware video acceleration support
• Professional audio/video editing tools

HARDWARE SUPPORT
• Wide range of hardware compatibility
• Modern graphics drivers (Intel, AMD, NVIDIA)
• Bluetooth and wireless support
• Printer and scanner support
• Touch screen and HiDPI display support
        """
        
        text_widget = tk.Text(content_frame, wrap=tk.WORD, bg='#ffffff', 
                             font=('Inter', 10), relief=tk.FLAT)
        text_widget.insert(tk.END, features_text.strip())
        text_widget.configure(state=tk.DISABLED)
        
        # Add scrollbar
        scrollbar = ttk.Scrollbar(content_frame, command=text_widget.yview)
        text_widget.configure(yscrollcommand=scrollbar.set)
        
        text_widget.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
    def create_support_tab(self):
        """Create the support tab"""
        tab_frame = ttk.Frame(self.notebook)
        self.notebook.add(tab_frame, text="Support")
        
        content_frame = ttk.Frame(tab_frame)
        content_frame.pack(fill=tk.BOTH, expand=True, padx=30, pady=30)
        
        # Support links
        support_label = ttk.Label(content_frame, text="Get Help and Support", 
                                font=('Inter', 14, 'bold'))
        support_label.pack(anchor=tk.W, pady=(0, 20))
        
        links_frame = ttk.Frame(content_frame)
        links_frame.pack(fill=tk.X, pady=(0, 30))
        
        self.create_link_button(links_frame, "🌐 Visit Ferret OS Website", 
                              "https://ferret-os.org")
        self.create_link_button(links_frame, "📖 Read Documentation", 
                              "https://docs.ferret-os.org")
        self.create_link_button(links_frame, "💬 Community Forum", 
                              "https://forum.ferret-os.org")
        self.create_link_button(links_frame, "🐛 Report Issues", 
                              "https://github.com/ferret-os/ferret/issues")
        
        # Local help
        local_help_label = ttk.Label(content_frame, text="Local Resources", 
                                   font=('Inter', 14, 'bold'))
        local_help_label.pack(anchor=tk.W, pady=(20, 15))
        
        local_frame = ttk.Frame(content_frame)
        local_frame.pack(fill=tk.X)
        
        ttk.Button(local_frame, text="📚 System Manual Pages", 
                  command=self.open_manual).pack(fill=tk.X, pady=5)
        ttk.Button(local_frame, text="🔍 Search Help", 
                  command=self.open_help_search).pack(fill=tk.X, pady=5)
        ttk.Button(local_frame, text="ℹ️ System Information", 
                  command=self.show_system_info).pack(fill=tk.X, pady=5)
        
    def create_link_button(self, parent, text, url):
        """Create a button that opens a URL"""
        button = ttk.Button(parent, text=text, 
                          command=lambda: webbrowser.open(url))
        button.pack(fill=tk.X, pady=5)
        
    def create_footer(self, parent):
        """Create the footer with action buttons"""
        footer_frame = ttk.Frame(parent)
        footer_frame.pack(fill=tk.X)
        
        # Checkbox for showing on startup
        self.show_on_startup = tk.BooleanVar(value=True)
        startup_check = ttk.Checkbutton(footer_frame, 
                                      text="Show this window on startup",
                                      variable=self.show_on_startup,
                                      command=self.toggle_startup)
        startup_check.pack(side=tk.LEFT)
        
        # Close button
        close_button = ttk.Button(footer_frame, text="Close", 
                                command=self.close_application)
        close_button.pack(side=tk.RIGHT, padx=(10, 0))
        
        # Install System button (if running live)
        if self.is_live_session():
            install_button = ttk.Button(footer_frame, text="Install Ferret OS", 
                                      command=self.launch_installer)
            install_button.pack(side=tk.RIGHT, padx=(10, 0))
    
    # Action methods
    def open_network_settings(self):
        """Open network configuration"""
        try:
            subprocess.Popen(['nm-connection-editor'])
        except:
            subprocess.Popen(['xfce4-settings-manager'])
    
    def update_system(self):
        """Launch system updater"""
        try:
            subprocess.Popen(['gnome-software', '--mode=updates'])
        except:
            subprocess.Popen(['xfce4-terminal', '-e', 'sudo apt update && sudo apt upgrade'])
    
    def open_app_store(self):
        """Open application store"""
        try:
            subprocess.Popen(['gnome-software'])
        except:
            subprocess.Popen(['synaptic'])
    
    def open_settings(self):
        """Open system settings"""
        subprocess.Popen(['xfce4-settings-manager'])
    
    def open_file_manager(self):
        """Open file manager"""
        subprocess.Popen(['thunar'])
    
    def open_terminal(self):
        """Open terminal"""
        subprocess.Popen(['xfce4-terminal'])
    
    def open_manual(self):
        """Open manual pages"""
        subprocess.Popen(['xfce4-terminal', '-e', 'man intro'])
    
    def open_help_search(self):
        """Open help search"""
        subprocess.Popen(['yelp'])
    
    def show_system_info(self):
        """Show system information"""
        try:
            result = subprocess.run(['uname', '-a'], capture_output=True, text=True)
            kernel_info = result.stdout.strip()
            
            result = subprocess.run(['lsb_release', '-d'], capture_output=True, text=True)
            distro_info = result.stdout.split(':')[1].strip() if ':' in result.stdout else "Ferret OS"
            
            info_text = f"Distribution: {distro_info}\nKernel: {kernel_info}"
            messagebox.showinfo("System Information", info_text)
        except:
            messagebox.showinfo("System Information", "Ferret OS - Modern Linux Distribution")
    
    def launch_installer(self):
        """Launch the system installer"""
        try:
            subprocess.Popen(['calamares'])
        except:
            messagebox.showerror("Error", "System installer not found")
    
    def is_live_session(self):
        """Check if running in live session"""
        return os.path.exists('/usr/bin/calamares') and os.path.exists('/cdrom')
    
    def toggle_startup(self):
        """Toggle showing on startup"""
        autostart_dir = Path.home() / '.config' / 'autostart'
        autostart_file = autostart_dir / 'ferret-welcome.desktop'
        
        if self.show_on_startup.get():
            # Create autostart entry
            autostart_dir.mkdir(parents=True, exist_ok=True)
            autostart_content = """[Desktop Entry]
Type=Application
Name=Ferret Welcome
Exec=ferret-welcome
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
"""
            autostart_file.write_text(autostart_content)
        else:
            # Remove autostart entry
            if autostart_file.exists():
                autostart_file.unlink()
    
    def close_application(self):
        """Close the application"""
        self.root.quit()
    
    def run(self):
        """Start the application"""
        self.root.mainloop()

def main():
    """Main entry point"""
    app = FerretWelcome()
    app.run()

if __name__ == "__main__":
    main()
