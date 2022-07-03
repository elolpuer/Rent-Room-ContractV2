//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.13;

import "../storage/RentStorage.sol";
import "../interfaces/IProperty.sol";
import "../interfaces/IRent.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Factory is Initializable, RentStorage, IRent {

    fallback() external payable{}
    receive() external payable{}

    function initialize(address _property) public initializer {
      property = IProperty(_property);
      // require(property.owner() == msg.sender, "Rent: Different owners");
    }

    modifier isRented(uint256 propertyID) {
      require(properties[propertyID].rented == false, "Factory: Property is rented");
      _;
    }

    modifier isPropertyOwner(uint256 propertyID) {
      require(properties[propertyID].owner == msg.sender, "Factory: Not property owner");
      _;
    }

    //create property with basic config and mint token
    function createProperty(uint256 price) public {
      uint256 id = property.mint(msg.sender);
      properties.push(
        Property(
          id,         //ID
          msg.sender, //Owner
          address(0), //Renter
          0,          //Time Deal
          0,          //Time Rent Will End
          price,      //Price
          false       //Rented
        )
      );
      emit CreateProperty(msg.sender, price, properties.length - 1);
    }

    function deleteProperty(uint256 propertyID) public isRented(propertyID) isPropertyOwner(propertyID) {
      uint256 tokenId = properties[propertyID].id;
      delete properties[propertyID];
      property.burn(tokenId, msg.sender);
      emit DeleteProperty(msg.sender, propertyID);
    }

    function getAllUserProperty(address user) public returns(Property[] memory){
      Property[] memory _userProperty = new Property[](property.userPropertyAmount(user));
      for (uint256 i = 0; i < properties.length; i++) {
        if (properties[i].owner == user) {
          _userProperty[i] = properties[i];
        }
      }
      return _userProperty;
    }

    // ///Выставляем комнату/квартиру для аренды
    // function sellRoom(string memory _name, string memory _description, uint _key, uint _price) public payable {
    //     require(_price != 0 && _key != 0, "Key and price can't be equal 0");
    //     keys[rooms.length] = _key;
    //     rooms.push(Room(rooms.length, payable(msg.sender), payable(address(0)), 0, 0, _name, _description, _price, false));
    //     emit SellRoom(payable(msg.sender), _price);
    // }
    //
    // //Все комнаты/квартиры
    // function getAllRooms() public view returns(Room[] memory _rooms){
    //     _rooms = rooms;
    // }
    //
    // //Арендуем комнату/квартиру
    // function rentRoom (uint _id) public payable {
    //     require(msg.sender != rooms[_id].Owner, 'Sender should be not owner');
    //     require(!rooms[_id].Rented, 'Already rent');
    //     require(rooms[_id].Price <= msg.value, 'Not enough money');
    //     //Вычисляем количество месяцев аренды
    //     uint monthRent = msg.value / rooms[_id].Price;
    //     //Забираем депозит в размере месячной платы
    //     deposit[_id] = rooms[_id].Price;
    //     //Отправляем остальное владельцу
    //     require(rooms[_id].Owner.send(msg.value - rooms[_id].Price), 'Oops, something failed');
    //     rooms[_id].TimeDeal = block.timestamp;
    //     rooms[_id].TimeRentEnded = block.timestamp + (30 days * monthRent);
    //     rooms[_id].RentOwner = payable(msg.sender);
    //     rooms[_id].Rented = true;
    //     emit RentRoom(rooms[_id].Owner, rooms[_id].RentOwner, _id ,rooms[_id].TimeDeal, rooms[_id].TimeRentEnded, rooms[_id].Price);
    // }
    //
    // //Закрываем комнату/квартиру от лица арендующего при этом отправляем депозит
    // function closeRoomRenter (uint _id) public payable {
    //     require(msg.sender == rooms[_id].RentOwner, 'Sender should be renter');
    //     if (rooms[_id].TimeDeal != 0){
    //         require(rooms[_id].RentOwner.send(deposit[_id]), 'Oops, something failed');
    //     }
    //     deposit[_id] = 0;
    //     rooms[_id].TimeDeal = 0;
    //     rooms[_id].TimeRentEnded = 0;
    //     rooms[_id].RentOwner = payable(address(0));
    //     rooms[_id].Rented = false;
    //     emit CloseRoomRenter(_id);
    // }
    //
    // //Навсегда закрываем комнату/квартиру навсегда от лица владельца
    // //При этом если остается время до закрытия сделки, скидываем оставшиеся деньги арендующему
    // function closeRoomOwnerForever (uint _id) public payable {
    //     require(msg.sender == rooms[_id].Owner, 'Sender should be owner');
    //     if (msg.value != 0 && rooms[_id].TimeDeal != 0){
    //         require(rooms[_id].RentOwner.send(msg.value + deposit[_id]),  'Oops, something failed');
    //     }
    //     deposit[_id] =0;
    //     if (_id >= rooms.length) return;
    //
    //     for (uint i = _id; i<rooms.length-1; i++){
    //         Room memory futureLast = rooms[i];
    //         rooms[i] = rooms[i+1];
    //         rooms[i].ID--;
    //         rooms[i+1] = futureLast;
    //         rooms[i+1].ID++;
    //     }
    //
    //     rooms.pop();
    //     emit CloseRoomOwnerForever(payable(msg.sender), _id);
    // }
    //
    // //Навсегда закрываем комнату/квартиру от этого рентера от лица владельца
    // //При этом если остается время до закрытия сделки, скидываем оставшиеся деньги арендующему
    // function closeRoomOwnerFromThisRenter (uint _id) public payable {
    //     require(msg.sender == rooms[_id].Owner, 'Sender should be owner');
    //     if (msg.value != 0 && rooms[_id].TimeDeal != 0){
    //         require(rooms[_id].RentOwner.send(msg.value + deposit[_id]));
    //     }
    //     deposit[_id] =0;
    //     rooms[_id].RentOwner = payable(address(0));
    //     rooms[_id].TimeDeal = 0;
    //     rooms[_id].TimeRentEnded = 0;
    //     rooms[_id].Rented = false;
    //     emit CloseRoomOwnerFromThisRenter(payable(msg.sender), _id);
    // }
    //
    // function getDeposit(uint _id) public view returns(uint){
    //     return deposit[_id];
    // }
    // //Меняем ключи
    // function changeKey(uint _id, uint _newKey) public {
    //     require(msg.sender == rooms[_id].Owner, 'Sender should be owner');
    //     keys[_id] = _newKey;
    //     emit ChangeKey(_id);
    // }
    //
    // //Получаем ключи
    // function getKey(uint _id) public view returns(uint){
    //     require(msg.sender == rooms[_id].Owner || msg.sender == rooms[_id].RentOwner, 'Sender should be owner or renter');
    //     return keys[_id];
    // }
}
