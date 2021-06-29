################################################################################
# Name: set_or_update_corne_var                                                #
# Purpose: this script sets or updates corner variables in a simulation        #
#          creating unique names for new corners or serching for existing ones #
# Release: 12/Jan/2021                                                         #
# Author: James Mutumba @ EDA Solutions Ltd.                                   #
# Contact: Support@eda-solutions.com                                           #
#                                                                              #
# Please use this script at your own discretion and responsbility. Even though #
# This script was tested and passed the QA criteria to meet the intended       #
# specifications and behaviors upon request, the user remains the primary      #
# responsible for the sanity of the results produced by the script.            #
# The user is always advised to check the created corners and make sure the    #
# correct data is present.                                                     #
#                                                                              #
# For further support or questions, please e-mail support@eda-solutions.com    #
#																			                                         #
# Test platform version: S-Edit 2020.3 Update 1 Release build 				         #
################################################################################ 


proc set_or_update_corner_var {cornerName varName values} {

  if { [property get -exists -name "CurrentTestbench"] } {
    set curBench [property get -name "CurrentTestbench" -host view]
  } else {
    set curBench "Spice"
  }

  property set -name "$curBench.Corners.CornerNames.$cornerName.Enable" -host view -value true -suppressupdateviews

  set maxvar -1
  set found -1
  foreach x [database properties] {
    if {[string match "$curBench.Corners.Variables.*" [lindex $x 0] ]} {
    
      set vid [lindex [split [lindex $x 0] .] 3]
      if {[expr "$vid > $maxvar"]} { 
        set maxvar $vid }
    }
    if {[string match "$curBench.Corners.Variables.*.Name" [lindex $x 0] ]} {
      if {[string match [lindex $x 1] $varName]} {
        set found [lindex [split [lindex $x 0] .] 3]
      }
    }
  }

  if {[expr "$found == -1"]} {
    set maxvar [expr "$maxvar +1"]
    property set -name "$curBench.Corners.Variables.$maxvar.Name" -value $varName -host view -suppressupdateviews
    property set -name "$curBench.Corners.Variables.$maxvar.VarType" -value Parameter -host view -suppressupdateviews
  }

  # now add value by setting a unique value using the rand() function
  #look for a cornername in database properties to see if it already exists(for updating)
  set found "${cornerName}_[expr "int(rand()*1000000)"]"
  foreach x [database properties] {
    if {[string match "$curBench.Corners.Values.*.CornerName" [lindex $x 0] ]} {
      if {[string match "$cornerName" [lindex $x 1]]} {
        set tag [lindex [split [lindex $x 0] .] 3]
        set cvar [property get -name "$curBench.Corners.Values.$tag.VarName" -host view]
        if {[string match "$cvar" "$varName"]} { 
          set found "$tag" 
          }
      }
    }
  }

  property set -name "$curBench.Corners.Values.$found.CornerName" -value $cornerName -host view -suppressupdateviews
  property set -name "$curBench.Corners.Values.$found.VarName" -value $varName -host view -suppressupdateviews
  property set -name "$curBench.Corners.Values.$found.Value" -value $values -host view -suppressupdateviews

  #sets the corner variable as a parameter but can be set as Temp/tclvariable etc
  property set -name "$curBench.Param.$varName" -host view -value 0 -suppressupdateviews 
}

proc set_my_corners {} {
  set_or_update_corner_var "MyCorner" "res" "3000"
  set_or_update_corner_var "MyCorner" "global" "-3 "
  set_or_update_corner_var "MyCorner" "n1p8" "-3 3"
  set_or_update_corner_var "MyCorner" "p1p8" "-3 3"
}

set_my_corners

#you can use set_my_corners to take the variables of corner/variable names and their values you want to create or update

