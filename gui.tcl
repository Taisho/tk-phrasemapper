#!/usr/bin/env wish

#TODO Move the popup on parent's <Configure> event
#TODO 

namespace eval ::text {

    proc configureTags {} {
        ::.text tag configure bold -font {Helvetica 18 bold}
    }

    proc trans_selected {} {
        set sindex [.popup.combo curselection]
        puts $sindex
    }

    proc enter {} {
        set width 180
        set height 180

        if {[winfo exists .popup] == 1} {
            enter_close
            return
        }

        tk::toplevel .popup
        wm overrideredirect .popup 1

        set tp_geometry [wm geometry .]
        set x 0
        set y 0
        regexp {\+([0-9]+)\+([0-9]+)} $tp_geometry -> x y

        set bbox [::.text bbox [::.text index sel.first]]
        set x [expr $x + [lindex $bbox 0]]
        set y [expr $y + [lindex $bbox 1] + [lindex $bbox 3]]

        set geometry ${width}x$height+$x+$y
        wm geometry .popup $geometry

        pack [entry .popup.entry]
        pack [listbox .popup.combo] -fill x -expand yes
        pack [button .popup.bt_new -text {New Translation}]
        .popup.combo insert 0 {Some phrase} {Some phrase 2}

        bind .popup.combo <<ListboxSelect>> { ::text::trans_selected }
    }

    proc enter_close {} {
        if {[winfo exists .popup] == 1} {
            puts ".popup exists. Closing"
            destroy .popup.entry
            destroy .popup.combo
            destroy .popup.bt_new
            destroy .popup

            focus .text
        }
    }

    proc toggle { op } {
        set indeces [::.text tag nextrange sel 0.0]
        set index1 [lindex $indeces 0]
        set index2 [lindex $indeces 1]

        switch -- $op bold {
            set names [::.text tag names $index1]

            set toggled 0
            for { set i 0} { $i < [llength $names] } { incr i } {
                if { [string compare [lindex $names $i] bold] == 0} {
                    set toggled 1
                }
            }

            if { $toggled == 0 } {
                ::.text tag add bold $index1 $index2
            } else {
                ::.text tag remove bold $index1 $index2
            }
        }
    }
}

namespace eval ::kbd {
    variable ctrlPressed 0
    variable s_Pressed 0
    variable b_Pressed 0
    variable g_Pressed 0

    variable lock_Ctrl_s 0
    variable lock_Ctrl_b 0
    variable lock_Ctrl_g 0
    variable handler_Ctrl_s {}
    variable handler_Ctrl_b {}
    variable handler_Ctrl_g {}

    proc setHandler { seq script } {
        variable handler_Ctrl_s
        variable handler_Ctrl_b
        variable handler_Ctrl_g

        eval "set handler_$seq {$script} "
    }

    proc handle {} {
        variable ctrlPressed
        variable s_Pressed
        variable b_Pressed
        variable g_Pressed
        variable lock_Ctrl_s
        variable lock_Ctrl_b
        variable lock_Ctrl_g
        variable handler_Ctrl_s
        variable handler_Ctrl_b
        variable handler_Ctrl_g

        if { $ctrlPressed == 1 && $s_Pressed == 1 && $lock_Ctrl_s == 0} {
            set lock_Ctrl_s 1
            eval $handler_Ctrl_s
        } elseif { $ctrlPressed == 1 && $b_Pressed == 1 && $lock_Ctrl_b == 0} {
             set lock_Ctrl_b 1
             eval $handler_Ctrl_b
        } elseif { $ctrlPressed == 1 && $g_Pressed == 1 && $lock_Ctrl_g == 0} {
             set lock_Ctrl_g 1
             eval $handler_Ctrl_g
        }
     }

     proc key-press { n k } {
         variable ctrlPressed
         variable s_Pressed
         variable b_Pressed
         variable g_Pressed
         variable lock_Ctrl_s
         variable lock_Ctrl_b
         variable lock_Ctrl_g

         switch -- $k Control_L {
             set ctrlPressed 1
         } s {
             set s_Pressed 1
         } b {
             set b_Pressed 1
         } g {
             set g_Pressed 1
         }

         handle
     }

     proc key-release { n k } {
         variable ctrlPressed
         variable s_Pressed
         variable b_Pressed
         variable g_Pressed
         variable lock_Ctrl_b
         variable lock_Ctrl_g

         switch -- $k Control_L {
             set ctrlPressed 0
         } s {
             set s_Pressed 0
         } b {
             set b_Pressed 0
         } g {
             set g_Pressed 0
         }

        if { $s_Pressed == 0 && $ctrlPressed == 0} {
            set lock_Ctrl_s 0
        }
        if { $b_Pressed == 0 || $ctrlPressed == 0} {
            set lock_Ctrl_b 0
        }
        if { $g_Pressed == 0 || $ctrlPressed == 0} {
            set lock_Ctrl_g 0
        }
    }
}


pack [text .text]
::text::configureTags

 #
 ##
 ### Pack the treeview and the frame in the PanedWindow
 ##
 #

bind .text <KeyPress> { ::kbd::key-press %N %K }
bind .text <KeyRelease> { ::kbd::key-release %N %K }
::kbd::setHandler Ctrl_s { save-page }
::kbd::setHandler Ctrl_b { ::text::toggle bold }
::kbd::setHandler Ctrl_g { ::text::enter }
bind .text <Button> { ::text::enter_close }
