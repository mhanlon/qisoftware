// _CalendarCreator_EOArchive.java
// Generated by EnterpriseObjects palette at Saturday, September 24, 2005 9:02:30 PM US/Pacific

import com.webobjects.eoapplication.*;
import com.webobjects.eocontrol.*;
import com.webobjects.eointerface.*;
import com.webobjects.eointerface.swing.*;
import com.webobjects.foundation.*;
import java.awt.*;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.table.*;
import javax.swing.text.*;

public class _CalendarCreator_EOArchive extends com.webobjects.eoapplication.EOArchive {
    com.webobjects.eointerface.swing.EOFrame _eoFrame0;
    com.webobjects.eointerface.swing.EOTextField _nsTextField0;
    javax.swing.JButton _nsButton0;
    javax.swing.JComboBox _nsComboBox0;
    javax.swing.JPanel _nsView0;

    public _CalendarCreator_EOArchive(Object owner, NSDisposableRegistry registry) {
        super(owner, registry);
    }

    protected void _construct() {
        Object owner = _owner();
        EOArchive._ObjectInstantiationDelegate delegate = (owner instanceof EOArchive._ObjectInstantiationDelegate) ? (EOArchive._ObjectInstantiationDelegate)owner : null;
        Object replacement;

        super._construct();

        _nsTextField0 = (com.webobjects.eointerface.swing.EOTextField)_registered(new com.webobjects.eointerface.swing.EOTextField(), "NSTextField1");
        _nsButton0 = (javax.swing.JButton)_registered(new javax.swing.JButton("Add Event"), "");

        if ((delegate != null) && ((replacement = delegate.objectForOutletPath(this, "calsComboBox")) != null)) {
            _nsComboBox0 = (replacement == EOArchive._ObjectInstantiationDelegate.NullObject) ? null : (javax.swing.JComboBox)replacement;
            _replacedObjects.setObjectForKey(replacement, "_nsComboBox0");
        } else {
            _nsComboBox0 = (javax.swing.JComboBox)_registered(new javax.swing.JComboBox(), "NSComboBox");
        }

        if ((delegate != null) && ((replacement = delegate.objectForOutletPath(this, "myWindow")) != null)) {
            _eoFrame0 = (replacement == EOArchive._ObjectInstantiationDelegate.NullObject) ? null : (com.webobjects.eointerface.swing.EOFrame)replacement;
            _replacedObjects.setObjectForKey(replacement, "_eoFrame0");
        } else {
            _eoFrame0 = (com.webobjects.eointerface.swing.EOFrame)_registered(new com.webobjects.eointerface.swing.EOFrame(), "Window");
        }

        _nsView0 = (JPanel)_eoFrame0.getContentPane();
    }

    protected void _awaken() {
        super._awaken();
        _nsButton0.addActionListener((com.webobjects.eointerface.swing.EOControlActionAdapter)_registered(new com.webobjects.eointerface.swing.EOControlActionAdapter(_owner(), "addEvent", _nsButton0), ""));

        if (_replacedObjects.objectForKey("_eoFrame0") == null) {
            _connect(_owner(), _eoFrame0, "myWindow");
        }

        if (_replacedObjects.objectForKey("_nsComboBox0") == null) {
            _connect(_owner(), _nsComboBox0, "calsComboBox");
        }

        if (_replacedObjects.objectForKey("_nsComboBox0") == null) {
            
        }
    }

    protected void _init() {
        super._init();
        _setFontForComponent(_nsTextField0, "Lucida Grande", 11, Font.PLAIN);
        _nsTextField0.setEditable(false);
        _nsTextField0.setOpaque(false);
        _nsTextField0.setText("Add to Calendar:");
        _nsTextField0.setHorizontalAlignment(javax.swing.JTextField.LEFT);
        _nsTextField0.setSelectable(false);
        _nsTextField0.setEnabled(true);
        _nsTextField0.setBorder(null);
        _setFontForComponent(_nsButton0, "Lucida Grande", 11, Font.PLAIN);
        _nsButton0.setMargin(new Insets(0, 2, 0, 2));
        if (!(_nsView0.getLayout() instanceof EOViewLayout)) { _nsView0.setLayout(new EOViewLayout()); }
        _nsComboBox0.setSize(179, 22);
        _nsComboBox0.setLocation(28, 35);
        ((EOViewLayout)_nsView0.getLayout()).setAutosizingMask(_nsComboBox0, EOViewLayout.MinYMargin);
        _nsView0.add(_nsComboBox0);
        _nsTextField0.setSize(129, 14);
        _nsTextField0.setLocation(25, 14);
        ((EOViewLayout)_nsView0.getLayout()).setAutosizingMask(_nsTextField0, EOViewLayout.MinYMargin);
        _nsView0.add(_nsTextField0);
        _nsButton0.setSize(60, 21);
        _nsButton0.setLocation(205, 102);
        ((EOViewLayout)_nsView0.getLayout()).setAutosizingMask(_nsButton0, EOViewLayout.MinYMargin);
        _nsView0.add(_nsButton0);

        if (_replacedObjects.objectForKey("_eoFrame0") == null) {
            _nsView0.setSize(277, 135);
            _eoFrame0.setTitle("CalendarCreator");
            _eoFrame0.setLocation(315, 594);
            _eoFrame0.setSize(277, 135);
        }
    }
}
