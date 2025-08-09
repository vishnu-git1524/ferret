#!/usr/bin/env python3
"""
Ferret OS Modern Welcome Application
A sleek, professional welcome experience for new users
"""

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('WebKit2', '4.0')

from gi.repository import Gtk, Gdk, GdkPixbuf, Gio, WebKit2
import os
import subprocess
import json
import threading
import webbrowser

class ModernWelcomeApp:
    def __init__(self):
        self.builder = Gtk.Builder()
        self.setup_ui()
        self.setup_css()
        
    def setup_ui(self):
        """Create the modern UI layout"""
        # Main window
        self.window = Gtk.Window()
        self.window.set_title("Welcome to Ferret OS")
        self.window.set_default_size(1000, 700)
        self.window.set_position(Gtk.WindowPosition.CENTER)
        self.window.set_resizable(False)
        
        # Header bar
        header_bar = Gtk.HeaderBar()
        header_bar.set_show_close_button(True)
        header_bar.set_title("Welcome to Ferret OS")
        header_bar.set_subtitle("Get started with your new system")
        self.window.set_titlebar(header_bar)
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        main_box.set_spacing(0)
        
        # Sidebar
        sidebar = self.create_sidebar()
        main_box.pack_start(sidebar, False, False, 0)
        
        # Content area
        self.content_stack = Gtk.Stack()
        self.content_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self.content_stack.set_transition_duration(300)
        
        # Add pages
        self.add_welcome_page()
        self.add_system_page()
        self.add_software_page()
        self.add_support_page()
        
        main_box.pack_start(self.content_stack, True, True, 0)
        
        self.window.add(main_box)
        self.window.connect("destroy", Gtk.main_quit)
        
    def setup_css(self):
        """Apply modern CSS styling"""
        css_provider = Gtk.CssProvider()
        css = """
        .welcome-window {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .sidebar {
            background: #1e293b;
            color: #f8fafc;
            min-width: 280px;
        }
        
        .sidebar-item {
            padding: 16px 24px;
            border: none;
            background: transparent;
            color: #cbd5e1;
            font-size: 14px;
            font-weight: 500;
        }
        
        .sidebar-item:hover {
            background: #334155;
            color: #f8fafc;
        }
        
        .sidebar-item.active {
            background: #3b82f6;
            color: #ffffff;
        }
        
        .content-area {
            background: #ffffff;
            padding: 40px;
        }
        
        .welcome-title {
            font-size: 32px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 16px;
        }
        
        .welcome-subtitle {
            font-size: 18px;
            color: #64748b;
            margin-bottom: 32px;
        }
        
        .feature-card {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 24px;
            margin: 12px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .feature-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
            transition: all 0.3s ease;
        }
        
        .action-button {
            background: #3b82f6;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 600;
            font-size: 14px;
        }
        
        .action-button:hover {
            background: #2563eb;
        }
        
        .secondary-button {
            background: #e2e8f0;
            color: #475569;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 500;
            font-size: 14px;
        }
        
        .secondary-button:hover {
            background: #cbd5e1;
        }
        """
        
        css_provider.load_from_data(css.encode())
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
    
    def create_sidebar(self):
        """Create the modern sidebar navigation"""
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        sidebar.get_style_context().add_class("sidebar")
        
        # Logo and title
        logo_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        logo_box.set_margin_top(32)
        logo_box.set_margin_bottom(32)
        
        # Try to load Ferret OS logo
        try:
            logo_pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                "/usr/share/pixmaps/ferret-os-logo.svg", 64, 64, True
            )
            logo_image = Gtk.Image.new_from_pixbuf(logo_pixbuf)
        except:
            logo_image = Gtk.Image.new_from_icon_name("computer", Gtk.IconSize.DIALOG)
        
        logo_image.set_margin_bottom(16)
        logo_box.pack_start(logo_image, False, False, 0)
        
        title_label = Gtk.Label("Ferret OS")
        title_label.get_style_context().add_class("welcome-title")
        title_label.set_markup('<span color="#f8fafc" size="20000" weight="bold">Ferret OS</span>')
        logo_box.pack_start(title_label, False, False, 0)
        
        version_label = Gtk.Label("Version 1.0.0")
        version_label.set_markup('<span color="#94a3b8" size="11000">Version 1.0.0</span>')
        logo_box.pack_start(version_label, False, False, 0)
        
        sidebar.pack_start(logo_box, False, False, 0)
        
        # Navigation items
        nav_items = [
            ("Welcome", "welcome", "user-home"),
            ("System", "system", "computer"),
            ("Software", "software", "package-x-generic"),
            ("Support", "support", "help-about")
        ]
        
        for title, page, icon in nav_items:
            button = Gtk.Button()
            button.get_style_context().add_class("sidebar-item")
            
            button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            button_box.set_spacing(12)
            
            icon_image = Gtk.Image.new_from_icon_name(icon, Gtk.IconSize.BUTTON)
            button_box.pack_start(icon_image, False, False, 0)
            
            label = Gtk.Label(title)
            label.set_halign(Gtk.Align.START)
            button_box.pack_start(label, True, True, 0)
            
            button.add(button_box)
            button.connect("clicked", self.on_sidebar_clicked, page)
            
            sidebar.pack_start(button, False, False, 0)
        
        return sidebar
    
    def add_welcome_page(self):
        """Create the welcome page"""
        page = Gtk.ScrolledWindow()
        page.get_style_context().add_class("content-area")
        
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        content.set_margin_left(40)
        content.set_margin_right(40)
        content.set_margin_top(40)
        content.set_margin_bottom(40)
        
        # Hero section
        hero_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        hero_box.set_halign(Gtk.Align.CENTER)
        hero_box.set_margin_bottom(48)
        
        title = Gtk.Label()
        title.set_markup('<span size="40000" weight="bold" color="#1e293b">Welcome to Ferret OS</span>')
        title.set_margin_bottom(16)
        hero_box.pack_start(title, False, False, 0)
        
        subtitle = Gtk.Label()
        subtitle.set_markup('<span size="16000" color="#64748b">Fast, secure, and modern computing experience</span>')
        subtitle.set_margin_bottom(32)
        hero_box.pack_start(subtitle, False, False, 0)
        
        # Action buttons
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        button_box.set_spacing(16)
        button_box.set_halign(Gtk.Align.CENTER)
        
        install_button = Gtk.Button("Install Ferret OS")
        install_button.get_style_context().add_class("action-button")
        install_button.connect("clicked", self.on_install_clicked)
        button_box.pack_start(install_button, False, False, 0)
        
        tour_button = Gtk.Button("Take a Tour")
        tour_button.get_style_context().add_class("secondary-button")
        tour_button.connect("clicked", self.on_tour_clicked)
        button_box.pack_start(tour_button, False, False, 0)
        
        hero_box.pack_start(button_box, False, False, 0)
        content.pack_start(hero_box, False, False, 0)
        
        # Features grid
        features_grid = Gtk.Grid()
        features_grid.set_column_spacing(24)
        features_grid.set_row_spacing(24)
        features_grid.set_column_homogeneous(True)
        
        features = [
            ("🚀", "Fast Performance", "Optimized for speed with modern hardware support"),
            ("🔒", "Secure by Default", "Built-in firewall and security features"),
            ("🎨", "Beautiful Design", "Modern interface with professional aesthetics"),
            ("📦", "Rich Software", "Access to thousands of applications"),
            ("💻", "Developer Ready", "Pre-installed development tools"),
            ("🌐", "Always Connected", "Excellent network and WiFi support")
        ]
        
        for i, (icon, title, desc) in enumerate(features):
            card = self.create_feature_card(icon, title, desc)
            features_grid.attach(card, i % 3, i // 3, 1, 1)
        
        content.pack_start(features_grid, True, True, 0)
        
        page.add(content)
        self.content_stack.add_named(page, "welcome")
    
    def create_feature_card(self, icon, title, description):
        """Create a feature card"""
        card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        card.get_style_context().add_class("feature-card")
        card.set_spacing(12)
        
        icon_label = Gtk.Label()
        icon_label.set_markup(f'<span size="32000">{icon}</span>')
        card.pack_start(icon_label, False, False, 0)
        
        title_label = Gtk.Label()
        title_label.set_markup(f'<span size="14000" weight="bold" color="#1e293b">{title}</span>')
        card.pack_start(title_label, False, False, 0)
        
        desc_label = Gtk.Label(description)
        desc_label.set_line_wrap(True)
        desc_label.set_max_width_chars(30)
        desc_label.get_style_context().add_class("text-muted")
        card.pack_start(desc_label, False, False, 0)
        
        return card
    
    def add_system_page(self):
        """Create the system information page"""
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        page.get_style_context().add_class("content-area")
        
        title = Gtk.Label()
        title.set_markup('<span size="24000" weight="bold" color="#1e293b">System Information</span>')
        title.set_halign(Gtk.Align.START)
        title.set_margin_bottom(24)
        page.pack_start(title, False, False, 0)
        
        # System info grid
        info_grid = Gtk.Grid()
        info_grid.set_column_spacing(24)
        info_grid.set_row_spacing(16)
        
        system_info = self.get_system_info()
        
        for i, (label, value) in enumerate(system_info.items()):
            label_widget = Gtk.Label(f"{label}:")
            label_widget.set_halign(Gtk.Align.START)
            label_widget.get_style_context().add_class("font-weight-bold")
            
            value_widget = Gtk.Label(value)
            value_widget.set_halign(Gtk.Align.START)
            value_widget.set_line_wrap(True)
            
            info_grid.attach(label_widget, 0, i, 1, 1)
            info_grid.attach(value_widget, 1, i, 1, 1)
        
        page.pack_start(info_grid, False, False, 0)
        
        self.content_stack.add_named(page, "system")
    
    def add_software_page(self):
        """Create the software installation page"""
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        page.get_style_context().add_class("content-area")
        
        title = Gtk.Label()
        title.set_markup('<span size="24000" weight="bold" color="#1e293b">Essential Software</span>')
        title.set_halign(Gtk.Align.START)
        title.set_margin_bottom(24)
        page.pack_start(title, False, False, 0)
        
        # Software categories
        categories = [
            ("Productivity", ["LibreOffice", "GIMP", "Thunderbird"]),
            ("Development", ["Visual Studio Code", "Git", "Docker"]),
            ("Media", ["VLC", "Audacity", "Blender"]),
            ("Internet", ["Firefox", "Chrome", "Telegram"])
        ]
        
        for category, apps in categories:
            category_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            category_box.set_margin_bottom(32)
            
            category_label = Gtk.Label()
            category_label.set_markup(f'<span size="16000" weight="bold" color="#475569">{category}</span>')
            category_label.set_halign(Gtk.Align.START)
            category_label.set_margin_bottom(12)
            category_box.pack_start(category_label, False, False, 0)
            
            apps_grid = Gtk.FlowBox()
            apps_grid.set_max_children_per_line(4)
            apps_grid.set_selection_mode(Gtk.SelectionMode.NONE)
            
            for app in apps:
                app_button = Gtk.Button(f"Install {app}")
                app_button.get_style_context().add_class("secondary-button")
                app_button.connect("clicked", self.on_install_app, app)
                apps_grid.add(app_button)
            
            category_box.pack_start(apps_grid, False, False, 0)
            page.pack_start(category_box, False, False, 0)
        
        self.content_stack.add_named(page, "software")
    
    def add_support_page(self):
        """Create the support and resources page"""
        page = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        page.get_style_context().add_class("content-area")
        
        title = Gtk.Label()
        title.set_markup('<span size="24000" weight="bold" color="#1e293b">Support & Resources</span>')
        title.set_halign(Gtk.Align.START)
        title.set_margin_bottom(24)
        page.pack_start(title, False, False, 0)
        
        # Support links
        support_items = [
            ("📚", "Documentation", "Complete user guide and tutorials", "https://ferret-os.org/docs"),
            ("🐛", "Report Bug", "Help improve Ferret OS", "https://github.com/ferret-os/ferret/issues"),
            ("💬", "Community", "Join our community forum", "https://community.ferret-os.org"),
            ("📧", "Contact", "Get in touch with our team", "mailto:support@ferret-os.org")
        ]
        
        for icon, title, desc, url in support_items:
            item_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            item_box.set_spacing(16)
            item_box.set_margin_bottom(16)
            
            icon_label = Gtk.Label()
            icon_label.set_markup(f'<span size="24000">{icon}</span>')
            item_box.pack_start(icon_label, False, False, 0)
            
            content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            content_box.set_spacing(4)
            
            title_label = Gtk.Label()
            title_label.set_markup(f'<span size="14000" weight="bold" color="#1e293b">{title}</span>')
            title_label.set_halign(Gtk.Align.START)
            content_box.pack_start(title_label, False, False, 0)
            
            desc_label = Gtk.Label(desc)
            desc_label.set_halign(Gtk.Align.START)
            desc_label.get_style_context().add_class("text-muted")
            content_box.pack_start(desc_label, False, False, 0)
            
            item_box.pack_start(content_box, True, True, 0)
            
            open_button = Gtk.Button("Open")
            open_button.get_style_context().add_class("secondary-button")
            open_button.connect("clicked", self.on_open_url, url)
            item_box.pack_start(open_button, False, False, 0)
            
            page.pack_start(item_box, False, False, 0)
        
        self.content_stack.add_named(page, "support")
    
    def get_system_info(self):
        """Get system information"""
        info = {}
        
        try:
            # OS information
            with open('/etc/os-release', 'r') as f:
                for line in f:
                    if line.startswith('PRETTY_NAME='):
                        info['Operating System'] = line.split('=')[1].strip().strip('"')
                        break
            
            # Kernel version
            with open('/proc/version', 'r') as f:
                kernel_info = f.read().split()[2]
                info['Kernel'] = kernel_info
            
            # Memory information
            with open('/proc/meminfo', 'r') as f:
                for line in f:
                    if line.startswith('MemTotal:'):
                        mem_kb = int(line.split()[1])
                        mem_gb = round(mem_kb / 1024 / 1024, 1)
                        info['Memory'] = f"{mem_gb} GB"
                        break
            
            # CPU information
            with open('/proc/cpuinfo', 'r') as f:
                for line in f:
                    if line.startswith('model name'):
                        info['Processor'] = line.split(':')[1].strip()
                        break
        
        except Exception as e:
            info['Error'] = f"Could not retrieve system information: {e}"
        
        return info
    
    def on_sidebar_clicked(self, button, page):
        """Handle sidebar navigation"""
        self.content_stack.set_visible_child_name(page)
        
        # Update button states
        for child in button.get_parent().get_children():
            if hasattr(child, 'get_style_context'):
                child.get_style_context().remove_class("active")
        
        button.get_style_context().add_class("active")
    
    def on_install_clicked(self, button):
        """Launch the system installer"""
        try:
            subprocess.Popen(['pkexec', 'calamares'])
        except Exception as e:
            dialog = Gtk.MessageDialog(
                self.window, 0, Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                f"Could not launch installer: {e}"
            )
            dialog.run()
            dialog.destroy()
    
    def on_tour_clicked(self, button):
        """Start system tour"""
        # Switch to system page for now
        self.content_stack.set_visible_child_name("system")
    
    def on_install_app(self, button, app_name):
        """Install application"""
        button.set_sensitive(False)
        button.set_label(f"Installing {app_name}...")
        
        def install_thread():
            try:
                # This would typically install via flatpak or apt
                subprocess.run(['flatpak', 'install', '-y', app_name.lower()], 
                             capture_output=True, text=True)
                button.set_label(f"{app_name} Installed")
            except:
                button.set_label(f"Install {app_name}")
                button.set_sensitive(True)
        
        threading.Thread(target=install_thread, daemon=True).start()
    
    def on_open_url(self, button, url):
        """Open URL in default browser"""
        webbrowser.open(url)
    
    def run(self):
        """Start the application"""
        self.window.show_all()
        # Set welcome page as active initially
        self.content_stack.set_visible_child_name("welcome")
        Gtk.main()

def main():
    app = ModernWelcomeApp()
    app.run()

if __name__ == "__main__":
    main()
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
