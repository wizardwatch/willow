(defwindow time
	:monitor 0
	:windowtype "dock"
	:exclusive "true"
	:reserve (struts :side "top" :distance "45px")
        :geometry (geometry 	:x "0px"
	                        :y "0px"
				:width "100%"
				:height "10px"
                        	:anchor "top center")
	(windowtitle)
)
(defpoll time :interval "1s"
  "date '+%H:%M:%S %b %d, %Y'")
(defwidget sidestuff []
	(box 	:class "sidestuff"
		:orientation "h"
		:halign "end"
		time
	)
)
(defwidget workspaces []
  (box :class "workspaces"
       :orientation "h"
       :space-evenly true
       :halign "start"
       :spacing 10
    (button :onclick "wmctrl -s 0" 1)
    (button :onclick "wmctrl -s 1" 2)
    (button :onclick "wmctrl -s 2" 3)
    (button :onclick "wmctrl -s 3" 4)
    (button :onclick "wmctrl -s 4" 5)
    (button :onclick "wmctrl -s 5" 6)
    (button :onclick "wmctrl -s 6" 7)
    (button :onclick "wmctrl -s 7" 8)
    (button :onclick "wmctrl -s 8" 9)))
(defwidget middlestuff []
	(box :class "middlestuff"
		:halign "center"
	)
)
(defwidget windowtitle []
	(box  
		 :orientation "horizontal"
		(workspaces)
		(middlestuff)
		(sidestuff)	
	)
)
