import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:makani/blocs/cubits/user.dart';
import 'package:makani/blocs/cubits/map.dart';
import 'package:makani/data/models/categories.dart';
import 'package:makani/data/models/user.dart';
import 'package:makani/ui/utils/theme.dart';
import 'package:makani/ui/utils/utils.dart';

class New extends StatefulWidget {
  final bool isUpdate;

  const New({Key? key, this.isUpdate = false}) : super(key: key);

  @override
  _NewState createState() => _NewState();
}

class _NewState extends State<New> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  MUser? user;
  bool _isInitialized = false;
  bool _isSubCatValid = true;
  final DateTime _now = DateTime.now();
  Map<String, dynamic> _fields = {};

  _initState() {
    _isInitialized = true;
    user = context.watch<MUserCubit>().state;
    if (widget.isUpdate) {
      MapState mapState = context.watch<MapCubit>().state;
      int i = mapState.dataList
          .indexWhere((d) => d.makan.id == mapState.selectedMarker);
      _fields['id'] = mapState.dataList[i].makan.id;
      _fields['owner'] = mapState.dataList[i].makan.owner;
      _fields['category'] = mapState.dataList[i].makan.category;
      _fields['hobby'] = mapState.dataList[i].makan.hobby;
      _fields['business'] = mapState.dataList[i].makan.business;
      _fields['title'] = mapState.dataList[i].makan.title;
      _fields['details'] = mapState.dataList[i].makan.details;
      _fields['from'] = mapState.dataList[i].makan.from;
      _fields['to'] = mapState.dataList[i].makan.to;
    } else {
      _fields = {
        'category': 1,
        'hobby': 0,
        'business': 0,
        //because we don't use seconds then we must add a minute to make sure it's after _now
        'from': _now.add(Duration(minutes: 1)),
        'to': _now.add(Duration(hours: 50)), //later: change it to 2 hours
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) _initState();

    print('setState 1');
    print(_fields);

    return Scaffold(
      appBar: AppBar(
          title:
              Text(tr(widget.isUpdate ? "edit" : "add") + " " + tr("makan"))),
      body: (user == null ||
              (widget.isUpdate && user!.id != _fields['owner']) ||
              (widget.isUpdate && _fields['to'].isBefore(_now)))
          ? Container()
          : Form(
              key: _formKey,
              child: ListView(
                //don't use bottom padding because it'll be above keyboard
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SizedBox(height: 32),
                  _categoryField(),
                  SizedBox(height: 16),
                  _titleField(),
                  SizedBox(height: 16),
                  _detailsField(),
                  SizedBox(height: 16),
                  _fromField(),
                  SizedBox(height: 32),
                  _toField(),
                  SizedBox(height: 32),
                  _submitButton(),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _categoryField() {
    _isSubCatValid = !((_fields['category'] == 2 && _fields['hobby'] == 0) ||
        (_fields['category'] == 3 && _fields['business'] == 0));
    return Column(children: <Widget>[
      Row(children: [
        Icon(Icons.people, color: MTheme.formLabel),
        SizedBox(width: 18),
        Text(
          tr('shareWith'),
          style: TextStyle(
              color: _isSubCatValid ? MTheme.formLabel : MTheme.warningColor),
        ),
      ]),
      RadioListTile(
        value: 1,
        groupValue: _fields['category'],
        contentPadding: EdgeInsets.symmetric(horizontal: 28),
        onChanged: (_) => setState(() => _fields['category'] = 1),
        activeColor: MTheme.friendsColor,
        title: ExcludeSemantics(
          //temp to solve a bug in recognizer
          excluding: true,
          child: RichText(
            text: TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: MTheme.friendsColor),
              children: [
                TextSpan(text: tr("friendsDesc")),
                TextSpan(
                  text: tr("forMyFriends"),
                  style: Theme.of(context).textTheme.subtitle2,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.pushNamed(context, '/friends'),
                ),
                TextSpan(text: tr("only.")),
              ],
            ),
          ),
        ),
      ),
      RadioListTile(
        value: 2,
        groupValue: _fields['category'],
        contentPadding: EdgeInsets.symmetric(horizontal: 28),
        onChanged: (_) => setState(() => _fields['category'] = 2),
        activeColor: MTheme.publicColor,
        title: Text(tr("publicWithDesc"),
            style: TextStyle(color: MTheme.publicColor)),
      ),
      if (_fields['category'] == 2)
        DropdownButton(
          isDense: true,
          value: _fields['hobby'],
          style: TextStyle(color: MTheme.publicColor),
          onChanged: (value) => setState(() => _fields['hobby'] = value),
          items: hobbies
              .map((key, name) {
                return MapEntry(
                    key, DropdownMenuItem(value: key, child: Text(tr(name))));
              })
              .values
              .toList(),
        ),
      if (_fields['category'] == 2) SizedBox(height: 16),
      RadioListTile(
        value: 3,
        groupValue: _fields['category'],
        contentPadding: EdgeInsets.symmetric(horizontal: 28),
        onChanged: (_) => setState(() => _fields['category'] = 3),
        activeColor: MTheme.businessColor,
        title: Text(tr("businessWithDesc"),
            style: TextStyle(color: MTheme.businessColor)),
      ),
      if (_fields['category'] == 3)
        DropdownButton(
          isDense: true,
          value: _fields['business'],
          style: TextStyle(color: MTheme.businessColor),
          onChanged: (value) => setState(() => _fields['business'] = value),
          items: businesses
              .map((key, name) {
                return MapEntry(
                    key, DropdownMenuItem(value: key, child: Text(tr(name))));
              })
              .values
              .toList(),
        ),
      if (_fields['category'] == 3) SizedBox(height: 16),
      Divider(
        color: _isSubCatValid ? Colors.grey : MTheme.warningColor,
        thickness: 1,
        indent: 40,
      ),
      if (!_isSubCatValid)
        Row(children: [
          SizedBox(width: 40), // better than padding because rtl or ltr
          Text(
            tr('subCategoryError'),
            style: TextStyle(fontSize: 12, color: MTheme.warningColor),
          ),
        ]),
    ]);
  }

  Widget _titleField() {
    return TextFormField(
      decoration:
          InputDecoration(icon: Icon(Icons.edit), labelText: tr("title")),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => value!.trim().length < 3 ? tr("titleError") : null,
      onSaved: (value) => setState(() => _fields['title'] = value),
      initialValue: _fields['title'],
      maxLength: 30,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
    );
  }

  Widget _detailsField() {
    return TextFormField(
      decoration:
          InputDecoration(icon: Icon(Icons.edit), labelText: tr("details")),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) =>
          value!.trim().length < 3 ? tr("detailsError") : null,
      onSaved: (value) => setState(() => _fields['details'] = value),
      initialValue: _fields['details'],
      minLines: 1,
      maxLines: 4,
      maxLength: 300,
    );
  }

  Widget _fromField() {
    DateTime _value = _fields['from'];
    return InkWell(
      child: Column(children: [
        Row(children: [
          Icon(Icons.timelapse, color: MTheme.formLabel),
          SizedBox(width: 18),
          Text(tr('from'), style: TextStyle(color: MTheme.formLabel)),
        ]),
        Center(child: Text(Utils.formatDate(_fields["from"]))),
        Divider(color: Colors.grey, thickness: 1, indent: 40)
      ]),
      onTap: () => Utils.showSheet(
        context,
        child: Container(
            height: 180,
            child: CupertinoDatePicker(
              minimumDate: (widget.isUpdate && _fields['from'].isBefore(_now))
                  ? _fields['from']
                  : _now,
              maximumDate: _now.add(Duration(days: 365)),
              initialDateTime: _fields['from'],
              onDateTimeChanged: (value) => _value = value,
            )),
        onClicked: () {
          setState(() {
            _fields['from'] = _value;
            if (_fields['to'].isBefore(_fields['from']))
              _fields['to'] = _fields['from'].add(Duration(hours: 2));
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _toField() {
    DateTime _value = _fields['to'];
    return InkWell(
      child: Column(children: [
        Row(children: [
          Icon(Icons.timelapse, color: MTheme.formLabel),
          SizedBox(width: 18),
          Text(tr('to'), style: TextStyle(color: MTheme.formLabel)),
        ]),
        Center(child: Text(Utils.formatDate(_fields["to"]))),
        Divider(color: Colors.grey, thickness: 1, indent: 40)
      ]),
      onTap: () => Utils.showSheet(
        context,
        child: Container(
            height: 180,
            child: CupertinoDatePicker(
              minimumDate: _fields['from'],
              maximumDate: _now.add(Duration(days: 730)),
              initialDateTime: _fields['to'],
              onDateTimeChanged: (value) => _value = value,
            )),
        onClicked: () {
          setState(() => _fields['to'] = _value);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      child: Text(tr(widget.isUpdate ? "update" : "add")),
      style: ((_formKey.currentState?.validate() != null &&
                  !_formKey.currentState!.validate()) ||
              !_isSubCatValid)
          ? ButtonStyle(
              overlayColor: MaterialStateProperty.all(MTheme.warningColor))
          : ButtonStyle(),
      onPressed: () async {
        FocusScope.of(context).unfocus();
        if (_formKey.currentState!.validate() && _isSubCatValid) {
          _formKey.currentState!.save();
          Navigator.pop(context); //this screen
          if (widget.isUpdate) Navigator.pop(context); //details sheet
          await context.read<MapCubit>().update(
                debug: 'new: add/update',
                // if new makan, then make sure user will see his new makan,
                // if update the send null to keep the previous state
                makansFilters: widget.isUpdate ? null : [true, true, true],
                action: widget.isUpdate ? MapAction.Update : MapAction.Add,
                values: _fields,
                isTilesMode: true,
              );
        }
      },
    );
  }
}
