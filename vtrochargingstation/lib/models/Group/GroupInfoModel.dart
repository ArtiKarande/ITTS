/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class GroupInfoModel{

  var _createdBy, _createdOn, _type, _memberName, _memberContactNo, _nameInitial;

  GroupInfoModel(this._createdBy, this._createdOn, this._type, this._memberName,
      this._memberContactNo, this._nameInitial);

  get memberContactNo => _memberContactNo;

  set memberContactNo(value) {
    _memberContactNo = value;
  }

  get nameInitial => _nameInitial;

  set nameInitial(value) {
    _nameInitial = value;
  }

  get memberName => _memberName;

  set memberName(value) {
    _memberName = value;
  }

  get type => _type;

  set type(value) {
    _type = value;
  }

  get createdOn => _createdOn;

  set createdOn(value) {
    _createdOn = value;
  }

  get createdBy => _createdBy;

  set createdBy(value) {
    _createdBy = value;
  }
}