/*
 *
 *  * Created by Arti Karande in the year of 2020.
 *  * Copyright (c) 2020 Arti Karande. All rights reserved.
 *
 */

/// model class for getter and setter values
class GroupListModel{

  var _groupId, _groupName, _groupImage, _createdOn, _createdBy, _groupBalance;

  GroupListModel(this._groupId, this._groupName, this._groupImage, this._createdOn, this._createdBy, this._groupBalance);

  get groupBalance => _groupBalance;

  set groupBalance(value) {
    _groupBalance = value;
  }

  get createdBy => _createdBy;

  set createdBy(value) {
    _createdBy = value;
  }

  get createdOn => _createdOn;

  set createdOn(value) {
    _createdOn = value;
  }

  get groupImage => _groupImage;

  set groupImage(value) {
    _groupImage = value;
  }

  get groupName => _groupName;

  set groupName(value) {
    _groupName = value;
  }

  get groupId => _groupId;

  set groupId(value) {
    _groupId = value;
  }
}