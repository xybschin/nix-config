{
  config,
  pkgs,
  ...
}:

let
  c = config.lib.stylix.colors;
  rgba = hex: alpha: "#${hex}${alpha}";

  powermenu = pkgs.writeShellScript "rofi-powermenu" ''
    shutdown=" Shutdown"
    reboot=" Reboot"
    lock=" Lock"
    logout=" Logout"

    if [ -z "$1" ]; then
        echo -e "$shutdown\n$reboot\n$lock\n$logout"
    else
        case "$1" in
            *Shutdown*) hyprshutdown --post-cmd 'poweroff' ;;
            *Reboot*)   hyprshutdown --post-cmd 'reboot' ;;
            *Lock*)     hyprlock ;;
            *Logout*)   hyprctl dispatch "hl.dsp.exit()" ;;
        esac
    fi
  '';

  theme = ''
    configuration {
      modi:                "drun,run,window,ssh,power:${powermenu}";                      
      show-icons:          true;                                               
      display-drun:        "APPS";                                             
      display-run:         "RUN";                                              
      display-filebrowser: "FILES";                                            
      display-window:      "WINDOWS";                                          
      display-power:       "POWER";                                            
      display-ssh:         "SSH";                                            
      drun-display-format: "{name}";                                           
      drun-match-fields:   "name,generic";                                     
      window-format:       "{w} · {c} · {t}";                                  
    }                                                                          
                                                                               
    * {                                                                        
        background:        ${rgba c.base00 "FF"};                              
        background-dim:    ${rgba c.base01 "FF"};                              
        foreground:        ${rgba c.base08 "FF"};                              
        foreground-dim:    ${rgba c.base04 "FF"};                              
        foreground-error:  ${rgba c.base0F "FF"};                              
        foreground-alert:  ${rgba c.base0A "FF"};                              
        accent:            ${rgba c.base05 "FF"};                              
        border-color:      ${rgba c.base01 "FF"};                              
                                                                               
        font: "JetBrainsMono Nerd Font 11";
    }                                                                          
                                                                               
    window {                                                                   
        background-color:  @background;                                        
        border:            1px;                                                
        border-color:      @border-color;                                      
        border-radius:     0px;                                                
        width:             700px;                                              
        padding:           0px;                                                
        location:          center;                                             
        anchor:            center;                                             
    }                                                                          
                                                                               
    mainbox {                                                                  
        background-color:  @background;                                        
        children:          [ mode-switcher-bar, inputbar, listview, message ]; 
        spacing:           0px;                                                
    }                                                                          
                                                                               
    mode-switcher {                                                            
        background-color:  @background;                                        
        border:            0px 0px 1px 0px;                                    
        border-color:      @border-color;                                      
        padding:           0px;                                                
        spacing:           0px;                                                
    }                                                                          
                                                                               
    mode-switcher-bar {                                                        
        background-color:  @background-dim;                                    
        fixed-height:      32px;                                               
        children:          [ mode-switcher ];                                  
        expand:            false;                                              
    }                                                                          
                                                                               
    button {                                                                   
        border:            1px;                                                
        border-color:      @border-color;                                      
        background-color:  @background;                                        
        text-color:        @foreground;                                        
        padding:           2px 20px;                                           
        expand:            false;                                              
        font:              "JetBrainsMono Nerd Font 9";                       
    }                                                                          
                                                                               
    button selected {                                                          
        background-color:  @background-dim;                                    
        text-color:        @accent;                                            
    }                                                                          
                                                                               
    inputbar {                                                                 
        background-color:  @background;                                        
        text-color:        @foreground;                                        
        padding:           16px 18px;                                          
        spacing:           10px;                                               
        children:          [ entry ];                                          
    }                                                                          
                                                                               
    prompt {                                                                   
        background-color:  transparent;                                        
        text-color:        @foreground-dim;                                    
    }                                                                          
                                                                               
    entry {                                                                    
        background-color:  transparent;                                        
        text-color:        @foreground-dim;                                    
        placeholder:       "Search...";                                        
        placeholder-color: @foreground-dim;                                    
    }                                                                          
                                                                               
    listview {                                                                 
        background-color:  @background;                                        
        border:            1px 0px 0px 0px;                                    
        border-color:      @border-color;                                      
        spacing:           4px;                                                
        lines:             6;                                                  
        columns:           1;                                                  
        fixed-height:      true;                                               
        dynamic:           false;                                              
    }                                                                          
                                                                               
    element {                                                                  
        background-color:  transparent;                                        
        text-color:        @foreground;                                        
        padding:           10px 12px;                                          
        spacing:           10px;                                               
        orientation:       horizontal;                                         
    }                                                                          
                                                                               
    element selected {                                                         
        background-color:  @background-dim;                                    
        text-color:        @accent;                                            
        border:            1px;                                                
        border-color:      @border-color;                                      
    }                                                                          
                                                                               
    element-icon {                                                             
        size:              24px;                                               
        background-color:  transparent;                                        
        vertical-align:    0.5;                                                
    }                                                                          
                                                                               
    element-text {                                                             
        background-color:  transparent;                                        
        text-color:        inherit;                                            
        vertical-align:    0.5;                                                
        horizontal-align:  0.0;                                                
    }                                                                          
                                                                               
    message {                                                                  
        enabled:           true;                                               
        margin:            0px;                                                
        padding:           0px;                                                
        border:            0px solid;                                          
        border-radius:     0px 0px 0px 0px;                                    
        border-color:      @border-color;                                      
        background-color:  transparent;                                        
        text-color:        @foreground;                                        
    }                                                                          
                                                                               
    textbox {                                                                  
        padding:           12px;                                               
        border:            0px solid;                                          
        border-radius:     0px;                                                
        border-color:      @border-color;                                      
        background-color:  @background-dim;                                    
        text-color:        @foreground-alert;                                  
        vertical-align:    0.5;                                                
        horizontal-align:  0.0;                                                
        highlight:         none;                                               
        placeholder-color: @foreground;                                        
        blink:             true;                                               
        markup:            true;                                               
    }                                                                          
                                                                               
    error-message {                                                            
        padding:           10px;                                               
        border:            2px solid;                                          
        border-radius:     0px;                                                
        border-color:      @border-color;                                      
        background-color:  @background;                                        
        text-color:        @foreground-error;                                  
    }

  '';
in
{
  stylix.targets.rofi.enable = false;

  xdg.dataFile."rofi/themes/koda.rasi".text = theme;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "koda";
    extraConfig = {
      terminal = "ghostty";
    };
  };
}
