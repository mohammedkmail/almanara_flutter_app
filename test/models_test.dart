import 'package:flutter_test/flutter_test.dart';
import 'package:al_manara_system/models/api_models.dart';
import 'package:al_manara_system/models/app_user_role.dart';
import 'package:al_manara_system/models/library_book.dart';

void main(){
 test('login response parses token and admin role',(){
  final result=LoginResponse.fromJson({'access_token':'abc','user':{'id':1,'username':'admin@library.com','fullName':'Admin','roles':['ROLE_ADMIN']}});
  expect(result.accessToken,'abc');expect(result.user!.role,AppUserRole.admin);
 });
 test('book response parses nested author/category and prices',(){
  final b=LibraryBook.fromJson({'id':1,'title':'Clean Code','author':{'name':'Robert Martin'},'category':{'name':'Software'},'available':true,'availableCopies':2,'borrowingFee':3});
  expect(b.author,'Robert Martin');expect(b.category,'Software');expect(b.availableCopies,2);expect(b.borrowingFee,3.0);
 });
}
