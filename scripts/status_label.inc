//
// Name: status label include file
// License: Public Domain
// Author: Matthew Gates
// Description: provide a simple status label function for use in other scripts
//

var rootLabelText = "";
var statusLabelId = -1;
var txt1="";

function useStatusLabel(root, x, y, size, color)
{
	rootLabelText = root
	statusLabelId = LabelMgr.labelScreen("", x, y, true, size, color);
}

function status(text)
{
	if (statusLabelId!=-1)
	{
		if (text!="")
		{
			LabelMgr.setLabelText(statusLabelId, rootLabelText + text);
		}
		else
		{
			LabelMgr.setLabelText(statusLabelId, "");
		}
	}
}

function message(txt)
{
    LabelMgr.setLabelShow(txt1, false);
    if (txt != "") {
        txt1 = LabelMgr.labelScreen(txt, 470, 120, false, 35, "#FF0000");
        LabelMgr.setLabelShow(txt1, true);
    }
}

