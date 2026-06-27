// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:EcommerceApp/helper/api/api_client.dart';
import 'package:EcommerceApp/helper/bottom_bar.dart';
import 'package:EcommerceApp/helper/spleshpage.dart';
import 'package:EcommerceApp/main.dart';
import 'package:EcommerceApp/model/addressmodel.dart';
import 'package:EcommerceApp/model/cartmodels.dart';
import 'package:EcommerceApp/model/cupancode.dart';
import 'package:EcommerceApp/model/ordermodel.dart';
import 'package:EcommerceApp/model/productmodel.dart';
import 'package:EcommerceApp/view/addaddress.dart';
import 'package:EcommerceApp/view/addressadd.dart';
import 'package:EcommerceApp/view/allproductspage.dart';
import 'package:EcommerceApp/view/categorypage.dart';
import 'package:EcommerceApp/view/categoryviewall.dart';
import 'package:EcommerceApp/view/changepassword.dart';
import 'package:EcommerceApp/view/checkoutpage.dart';
import 'package:EcommerceApp/view/contect_us.dart';
import 'package:EcommerceApp/view/fevorite.dart';
import 'package:EcommerceApp/view/filterpage.dart';
import 'package:EcommerceApp/view/forgotpasswordpage.dart';
import 'package:EcommerceApp/view/homepage.dart';
import 'package:EcommerceApp/view/htmlcontain.dart';
import 'package:EcommerceApp/view/intropage.dart';
import 'package:EcommerceApp/view/ligalpolicy.dart';
import 'package:EcommerceApp/view/loginpage.dart';
import 'package:EcommerceApp/view/mostinterestedpage.dart';
import 'package:EcommerceApp/view/myaddress.dart';
import 'package:EcommerceApp/view/myorder.dart';
import 'package:EcommerceApp/view/successpage.dart';
import 'package:EcommerceApp/view/notificationpage.dart';
import 'package:EcommerceApp/view/orderdetails.dart';
import 'package:EcommerceApp/view/populerpage.dart';
import 'package:EcommerceApp/view/product_detail_page.dart';
import 'package:EcommerceApp/view/profilepage.dart';
import 'package:EcommerceApp/view/profileupdate.dart';
import 'package:EcommerceApp/view/registerpage.dart';
import 'package:EcommerceApp/view/reviewspage.dart';
import 'package:EcommerceApp/view/searchpage.dart';
import 'package:EcommerceApp/view/shopping.dart';
import 'package:EcommerceApp/view/tryon_page.dart';
import 'package:EcommerceApp/view/tryon_history_page.dart';
import 'package:EcommerceApp/view/verifyotp.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class HomeLocation extends BeamLocation<BeamState> {
  HomeLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/HomePage'), title: "HomePage", child: HomePage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/HomePage'];
}

class SpleshLocation extends BeamLocation<BeamState> {
  SpleshLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/SpleshPage'),
            title: "SpleshPage",
            child: SpleshPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/SpleshPage'];
}

class BottomBarLocation extends BeamLocation<BeamState> {
  BottomBarLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/BottomBar'), title: "BottomBar", child: BottomBar())
      ];
  @override
  List<Pattern> get pathPatterns => ['/BottomBar'];
}

class FavoritePageLocation extends BeamLocation<BeamState> {
  FavoritePageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/FavoritePage'),
            title: "FavoritePage",
            child: FavoritePage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/FavoritePage'];
}

class FilterPageLocation extends BeamLocation<BeamState> {
  FilterPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/FilterPage'),
            title: "FilterPage",
            child: FilterPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/FilterPage'];
}

class ForgotpasswordPageLocation extends BeamLocation<BeamState> {
  ForgotpasswordPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/ForgotpasswordPage'),
            title: "ForgotpasswordPage",
            child: ForgotpasswordPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/ForgotpasswordPage'];
}

// class ProductDetailScreenLocation extends BeamLocation<BeamState> {
//   var title;
//   ProductDetailScreenLocation(RouteInformation delegate, BeamParameters data)
//       : super(delegate, data);

//   List<BeamPage> buildPages(BuildContext context, BeamState state) {
//     dynamic datas = data;
//     List<ProductModel> product = [];
//     ProductModel productModel;
//     String productName = 'Unknown';
//     int detailindex = 0;
//     // final productName = datas['productName'] ?? 'Unknown';
//     if (datas != null && datas['productModelList'] != null) {
//       product = datas['productModelList'];
//       productModel = datas['productModel'];
//       productName = datas['productName'] ?? 'Unknown';
//       title = productModel.title;
//       perfs!.setString('productModel', jsonEncode(datas['productModel']));
//       perfs!.setString('productindex', datas['index'].toString());
//       perfs!.setString(
//           'productModelList',
//           jsonEncode(product.map((e) {
//             return e.toJson();
//           }).toList()));
//     } else {
//       var data = jsonDecode(perfs!.getString('productModel') ?? "");
//       String dataproductModelLists = perfs!.getString('productModelList') ?? "";
//       String productindex = perfs!.getString('productindex') ?? "";
//       productName = perfs!.getString('productName') ?? "";

//       DocumentSnapshot<Map<String, dynamic>> mockDocument =
//           MockDocumentSnapshot("id", data);

//       productModel = ProductModel.fromSnapshot(mockDocument);
//       title = productModel.title;
//       print("product done productModel :: ${productModel}");
//       List<dynamic> product111 = jsonDecode(dataproductModelLists);

//       product111.forEach(
//         (element) {
//           DocumentSnapshot<Map<String, dynamic>> mockDocument =
//               MockDocumentSnapshot("id", element);

//           ProductModel products = ProductModel.fromSnapshot(mockDocument);
//           product.add(products);
//         },
//       );
//       detailindex = int.parse(productindex);
//     }
//     return [
//       BeamPage(
//           key: ValueKey('/ProductDetailScreen-$productName'),
//           title: "ProductDetailScreen-$productName",
//           child: ProductDetailScreen(
//             title: (datas != null && datas['productName'] != null)
//                 ? datas['productName']
//                 : productName,
//             index: (datas != null && datas['index'] != null)
//                 ? datas['index']
//                 : detailindex,
//             productModel: (datas != null && datas['productModel'] != null)
//                 ? datas['productModel']
//                 : productModel,
//             productModelList:
//                 (datas != null && datas['productModelList'] != null)
//                     ? datas['productModelList']
//                     : product,
//           ))
//     ];
//   }

//   @override
//   List<Pattern> get pathPatterns => ['/ProductDetailScreen/:productName'];
// }

class ProductDetailScreenLocation extends BeamLocation<BeamState> {
  var title;
  ProductDetailScreenLocation(RouteInformation super.delegate, BeamParameters super.data);

  // Fetch products from the Node/MongoDB backend.
  Future<List<ProductModel>> ProductsDataGet() async {
    try {
      final list = await ApiClient.instance.getList('/products');
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;

    ProductModel? productModel;
    String productName = 'Unknown';
    int detailIndex = 0;
    List<ProductModel> productList = [];

    // Check if data is empty and try to fetch from local storage
    if (datas != null && datas['productModelList'] != null) {
      productList = datas['productModelList'];
      productModel = datas['productModel'];
      productName = datas['productName'] ?? 'Unknown';
      title = productModel!.title;

      // Store in shared preferences
      perfs!.setString('productModel', jsonEncode(datas['productModel']));
      perfs!.setString('productindex', datas['index'].toString());
      perfs!.setString('productModelList',
          jsonEncode(productList.map((e) => e.toJson()).toList()));
    } else {
      // Try to get data from shared preferences
      var storedData = jsonDecode(perfs!.getString('productModel') ?? "{}");

      Uri uri = Uri.base;
      String extractedProductName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last.replaceAll('-', ' ')
          : '';

      if (storedData.isEmpty) {
        return [
          BeamPage(
              key: ValueKey('/ProductDetailScreen-loading'),
              title: "Loading...",
              child: FutureBuilder<List<ProductModel>>(
                future: ProductsDataGet(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: Colors.black,
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading products"));
                  }

                  List<ProductModel> products = snapshot.data ?? [];
                  ProductModel? foundProduct;
                  try {
                    foundProduct = products.firstWhere(
                      (p) => p.title == extractedProductName,
                      orElse: () => products.isNotEmpty
                          ? products[0]
                          : ProductModel.empty(),
                    );
                  } catch (e) {
                  }

                  if (foundProduct != null) {
                    perfs?.setString('productModel', jsonEncode(foundProduct));
                    // perfs?.setString('productindex',
                    //     products.indexOf(foundProduct).toString());
                    perfs?.setString('productModelList',
                        jsonEncode(products.map((e) => e.toJson()).toList()));
                  }

                  return ProductDetailScreen(
                    title: foundProduct?.title ?? 'Unknown',
                    index: products.indexOf(foundProduct ?? products.first),
                    productModel: foundProduct,
                    productModelList: products,
                  );
                },
              ))
        ];
      } else {
        productModel =
            ProductModel.fromJson(Map<String, dynamic>.from(storedData));
        title = productModel.title;

        String storedProductList = perfs!.getString('productModelList') ?? "[]";
        List<dynamic> decodedList = jsonDecode(storedProductList);

        productList = decodedList.map((element) {
          return ProductModel.fromJson(Map<String, dynamic>.from(element));
        }).toList();

        detailIndex = int.parse(perfs!.getString('productindex') ?? "0");

        productName = perfs!.getString('productName') ?? 'Unknown';
      }
    }

    return [
      BeamPage(
          key: ValueKey('/ProductDetailScreen-$productName'),
          title: "ProductDetailScreen-$productName",
          child: ProductDetailScreen(
            title: (datas != null && datas['productName'] != null)
                ? datas['productName']
                : productName,
            index: (datas != null && datas['index'] != null)
                ? datas['index']
                : detailIndex,
            productModel: (datas != null && datas['productModel'] != null)
                ? datas['productModel']
                : productModel,
            productModelList:
                (datas != null && datas['productModelList'] != null)
                    ? datas['productModelList']
                    : productList,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/ProductDetailScreen/:productName'];
}

class TryOnLocation extends BeamLocation<BeamState> {
  TryOnLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    String productId = '';
    String productName = 'Try On';
    String thumbnail = '';

    if (datas != null && datas['productId'] != null) {
      productId = datas['productId'].toString();
      productName = (datas['productName'] ?? 'Try On').toString();
      thumbnail = (datas['thumbnail'] ?? '').toString();
      // Persist so a web refresh on /TryOn/... still works.
      perfs!.setString('tryonProductId', productId);
      perfs!.setString('tryonProductName', productName);
      perfs!.setString('tryonThumbnail', thumbnail);
    } else {
      productId = perfs!.getString('tryonProductId') ?? '';
      productName = perfs!.getString('tryonProductName') ?? 'Try On';
      thumbnail = perfs!.getString('tryonThumbnail') ?? '';
    }

    return [
      BeamPage(
        key: ValueKey('/TryOn-$productId'),
        title: "TryOn-$productName",
        child: TryOnPage(
          productId: productId,
          productName: productName,
          thumbnail: thumbnail,
        ),
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/TryOn/:productName'];
}

class TryOnHistoryLocation extends BeamLocation<BeamState> {
  TryOnHistoryLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      const BeamPage(
        key: ValueKey('/TryOnHistory'),
        title: 'My Try-Ons',
        child: TryOnHistoryPage(),
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/TryOnHistory'];
}

class HtmlConainLocation extends BeamLocation<BeamState> {
  HtmlConainLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    String ConainName = 'Unknown';
    if (datas != null) {
      ConainName = datas['conainName'] ?? 'Unknown';
      perfs!.setString('htmldata', datas['htmldata'].toString());
      perfs!.setString('conainName', ConainName.toString());
    }
    String caller = "";
    if (datas == null) {
      caller = perfs!.getString('htmldata') ?? "";
      ConainName = perfs!.getString('conainName') ?? "";
    }
    return [
      BeamPage(
          key: ValueKey('/Page-$ConainName'),
          title: "Page-$ConainName",
          child: HtmlConain(
            title: (datas != null && datas['conainName'] != null)
                ? datas['conainName']
                : ConainName,
            htmldata: datas != null ? datas['htmldata'] : caller,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/Page/:conainName'];
}

class HtmlConainCopyLocation extends BeamLocation<BeamState> {
  HtmlConainCopyLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    String ConainName = 'Unknown';
    if (datas != null) {
      perfs!.setString('htmldata', datas['htmldata'].toString());
      perfs!.setString('conainName', ConainName.toString());

      ConainName = datas['conainName'] ?? 'Unknown';
    }
    String caller = "";
    if (datas == null) {
      caller = perfs!.getString('htmldata') ?? "";
    }
    return [
      BeamPage(
          key: ValueKey('/Pages-$ConainName'),
          title: "Pandiyajee",
          child: HtmlConain(
            title: (datas != null && datas['conainName'] != null)
                ? datas['conainName']
                : ConainName,
            htmldata: datas != null ? datas['htmldata'] : caller,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/Pages/:conainName'];
}

class LegalPolicyLocation extends BeamLocation<BeamState> {
  LegalPolicyLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      const BeamPage(
          key: ValueKey('/LegalPolicy'),
          title: "LegalPolicy",
          child: LegalPolicy())
      // BeamPage(
      //     key: ValueKey('/LegalPolicy'),
      //     title: "LegalPolicy",
      //     child: LegalPolicy(policies: ));
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/LegalPolicy'];
}

class IntroPageLocation extends BeamLocation<BeamState> {
  IntroPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/IntroPage'), title: "IntroPage", child: IntroPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/IntroPage'];
}

class LoginPageLocation extends BeamLocation<BeamState> {
  LoginPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    return [
      BeamPage(
          key: ValueKey('/LoginPage'),
          title: "LoginPage",
          child: LoginPage(
            refresh: datas != null
                ? datas['refresh']
                : () {
                  },
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/LoginPage'];
}

class MyaddressesLocation extends BeamLocation<BeamState> {
  MyaddressesLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/Myaddresses'),
            title: "Myaddresses",
            child: Myaddresses())
      ];
  @override
  List<Pattern> get pathPatterns => ['/Myaddresses'];
}

class MyOrderPageLocation extends BeamLocation<BeamState> {
  MyOrderPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/MyOrderPage'),
            title: "MyOrderPage",
            child: MyOrderPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/MyOrderPage'];
}

class SuccessPageLocation extends BeamLocation<BeamState> {
  SuccessPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final d = data;
    final bool isSuccess =
        (d is Map && d['isSuccess'] == false) ? false : true;
    return [
      BeamPage(
        key: ValueKey('/SuccessPage-$isSuccess'),
        title: "SuccessPage",
        child: SuccessPage(isSuccess: isSuccess),
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/SuccessPage'];
}

class NotificationPageLocation extends BeamLocation<BeamState> {
  NotificationPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/NotificationPage'),
            title: "NotificationPage",
            child: NotificationPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/NotificationPage'];
}

class DeliveryAdressaddLocation extends BeamLocation<BeamState> {
  DeliveryAdressaddLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/DeliveryAdressadd'),
            title: "DeliveryAdressadd",
            child: DeliveryAdressadd())
      ];
  @override
  List<Pattern> get pathPatterns => ['/DeliveryAdressadd'];
}

class VerifyotpLocation extends BeamLocation<BeamState> {
  VerifyotpLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    if (datas != null) {
      perfs!.setString('confirmationResult', datas['confirmationResult']);
      perfs!.setString('forceResendingToken', datas['forceResendingToken']);
      perfs!.setString('verificationId', datas['verificationId']);
    }
    String caller = "";
    String caller1 = "";
    String caller2 = "";
    if (datas == null) {
      caller = perfs!.getString('confirmationResult') ?? "";
      caller1 = perfs!.getString('forceResendingToken') ?? "";
      caller2 = perfs!.getString('verificationId') ?? "";
    }

    return [
      BeamPage(
          key: ValueKey('/Verifyotp'),
          title: "Verifyotp",
          child: Verifyotp(
            confirmationResult:
                datas != null ? datas['confirmationResult'] : caller,
            forceResendingToken:
                datas != null ? datas['forceResendingToken'] : caller1,
            verificationId: datas != null ? datas['verificationId'] : caller2,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/Verifyotp'];
}

class CategoryPageLocation extends BeamLocation<BeamState> {
  CategoryPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    if (datas != null && datas['id'] != null) {
      perfs!.setString('CategoryPageid', datas['id']);
      if (datas['subname'] != null) {
        perfs!.setString('SubCategoryPageid', datas['subname']);
      }
    }
    String caller = "";
    var SubCategoryPageid = "";
    String categoryName = 'Unknown';

    if (datas == null) {
      caller = perfs!.getString('CategoryPageid') ?? "";
      categoryName = perfs!.getString('categoryName') ?? "";
      SubCategoryPageid = perfs!.getString('SubCategoryPageid') ?? "";
    }

    return [
      BeamPage(
          key: ValueKey('/CategoryPage-$categoryName'),
          title: "CategoryPage-$categoryName",
          child: CategoryPage(
            title: (datas != null && datas['subname'] != null)
                ? datas['subname']
                : categoryName,
            id: (datas != null && datas['id'] != null) ? datas['id'] : caller,
            subname: (datas != null && datas['subname'] != null)
                ? datas['subname']
                : SubCategoryPageid,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/CategoryPage/:categoryName'];
}

class CategoryPageCopyLocation extends BeamLocation<BeamState> {
  CategoryPageCopyLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    if (datas != null && datas['id'] != null) {
      perfs!.setString('CategoryPageid', datas['id']);
      if (datas['subname'] != null) {
        perfs!.setString('SubCategoryPageid', datas['subname']);
      }
    }
    String caller = "";
    var SubCategoryPageid = "";
    String categoryName = 'Unknown';

    if (datas == null) {
      caller = perfs!.getString('CategoryPageid') ?? "";
      SubCategoryPageid = perfs!.getString('SubCategoryPageid') ?? "";
    }

    return [
      BeamPage(
          key: ValueKey('/CategoryPages'),
          title: "CategoryPage",
          child: CategoryPage(
            title: (datas != null && datas['subname'] != null)
                ? datas['subname']
                : categoryName,
            id: (datas != null && datas['id'] != null) ? datas['id'] : caller,
            subname: (datas != null && datas['subname'] != null)
                ? datas['subname']
                : SubCategoryPageid,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/CategoryPages/:categoryName'];
}

class ViewAllLocation extends BeamLocation<BeamState> {
  ViewAllLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    List<ProductModel> product = [];
    if (datas != null && datas['visitlist'] != null) {
      product = datas['visitlist'];

      perfs!.setString(
          'visitlist',
          jsonEncode(product.map((e) {
            return e.toJson();
          }).toList()));

    } else {
      var datas = perfs!.getString('visitlist') ?? "";

      List<dynamic> product111 = jsonDecode(datas);
      for (var element in product111) {
          ProductModel products =
              ProductModel.fromJson(Map<String, dynamic>.from(element));
          product.add(products);
        }
    }

    return [
      BeamPage(
          key: ValueKey('/ViewAll'),
          title: "ViewAll",
          child: ViewAll(
            visitlist: datas != null && datas['visitlist'] != null
                ? datas['visitlist']
                : product,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/ViewAll'];
}

class DeliveryAdressLocation extends BeamLocation<BeamState> {
  DeliveryAdressLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    List<Addresslist> addresslist = [];
    int addressindex = 0;
    if (datas != null) {
      addresslist = datas['addresslist'];

      perfs!.setString('addressindex', datas['index'].toString());
      perfs!.setString(
          'addresslist',
          jsonEncode(addresslist.map((e) {
            return e.toJson();
          }).toList()));
    } else {
      String index = perfs!.getString('addressindex') ?? "";
      String addresslists = perfs!.getString('addresslist') ?? "";

      List<dynamic> address = jsonDecode(addresslists);
      for (var element in address) {
          Addresslist addresscontion = Addresslist.fromJson(element);
          addresslist.add(addresscontion);
        }
      addressindex = int.parse(index);
    }
    return [
      BeamPage(
          key: ValueKey('/DeliveryAdress'),
          title: "DeliveryAdress",
          child: DeliveryAdress(
            addresslist: datas != null ? datas['addresslist'] : addresslist,
            index: datas != null ? datas['index'] : addressindex,
            addaddress: false,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/DeliveryAdress'];
}

class DeliveryAdressaddsLocation extends BeamLocation<BeamState> {
  DeliveryAdressaddsLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
          key: ValueKey('/DeliveryAdressadds'),
          title: "DeliveryAdressadds",
          child: DeliveryAdress(
            addaddress: true,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/DeliveryAdressadds'];
}

class OrderDetailsLocation extends BeamLocation<BeamState> {
  OrderDetailsLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;

    int orderindex = 0;
    FirebaseOrderModel firebaseOrderModel = FirebaseOrderModel();
    if (datas != null) {
      firebaseOrderModel = datas['ordermodel'];
      perfs!.setString('orderindex', datas['index'].toString());
      perfs!.setString(
          'firebaseOrderModel', jsonEncode(firebaseOrderModel.toJson()));
    } else {
      var index = perfs!.getString('orderindex') ?? "";
      String orderModels = perfs!.getString('firebaseOrderModel') ?? "";
      dynamic data = json.decode(orderModels);
      firebaseOrderModel = FirebaseOrderModel.fromJson(data);

      orderindex = int.parse(index);
    }
    return [
      BeamPage(
          key: ValueKey('/OrderDetails'),
          title: "OrderDetails",
          child: OrderDetails(
            index: datas != null ? datas['index'] : orderindex,
            ordermodel:
                datas != null ? datas['ordermodel'] : firebaseOrderModel,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/OrderDetails'];
}

class PopularPageLocation extends BeamLocation<BeamState> {
  PopularPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    List<ProductModel> product = [];
    if (datas != null) {
      product = datas['visitlist'];

      perfs!.setString(
          'populervisitlist',
          jsonEncode(product.map((e) {
            return e.toJson();
          }).toList()));
    } else {
      var populervisitlist = perfs!.getString('populervisitlist') ?? "";

      List<dynamic> product111 = jsonDecode(populervisitlist);
      for (var element in product111) {
          ProductModel products =
              ProductModel.fromJson(Map<String, dynamic>.from(element));
          product.add(products);
        }
    }
    return [
      BeamPage(
          key: ValueKey('/PopularPage'),
          title: "PopularPage",
          child: PopularPage(
            visitlist: datas != null ? datas['visitlist'] : product,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/PopularPage'];
}

class ProfilePageLocation extends BeamLocation<BeamState> {
  ProfilePageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/ProfilePage'),
            title: "ProfilePage",
            child: ProfilePage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/ProfilePage'];
}

class RegisterPageLocation extends BeamLocation<BeamState> {
  RegisterPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;

    bool isdailog = false;
    if (datas != null) {
      perfs!.setBool('isdailog', datas['isdailog']);
    } else {
      isdailog = perfs!.getBool('isdailog') ?? false;
    }
    return [
      BeamPage(
          key: ValueKey('/RegisterPage'),
          title: "RegisterPage",
          child: RegisterPage(
              // isDailog: datas != null ? datas['isdailog'] : isdailog,
              ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/RegisterPage'];
}

class ReviewPageLocation extends BeamLocation<BeamState> {
  ReviewPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/ReviewPage'),
            title: "ReviewPage",
            child: ReviewPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/ReviewPage'];
}

class SearchPageLocation extends BeamLocation<BeamState> {
  SearchPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/SearchPage'),
            title: "SearchPage",
            child: SearchPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/SearchPage'];
}

class ShoppingPageLocation extends BeamLocation<BeamState> {
  ShoppingPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/ShoppingPage'),
            title: "ShoppingPage",
            child: ShoppingPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/ShoppingPage'];
}

class UpdateProfileLocation extends BeamLocation<BeamState> {
  UpdateProfileLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/UpdateProfile'),
            title: "UpdateProfile",
            child: UpdateProfile())
      ];
  @override
  List<Pattern> get pathPatterns => ['/UpdateProfile'];
}

class ChnagepasswordPageLocation extends BeamLocation<BeamState> {
  ChnagepasswordPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/ChnagepasswordPage'),
            title: "ChnagepasswordPage",
            child: ChnagepasswordPage())
      ];
  @override
  List<Pattern> get pathPatterns => ['/ChnagepasswordPage'];
}

class ContectUsLocation extends BeamLocation<BeamState> {
  ContectUsLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey('/ContectUs'), title: "ContectUs", child: ContectUs())
      ];
  @override
  List<Pattern> get pathPatterns => ['/ContectUs'];
}

class CheckoutPageLocation extends BeamLocation<BeamState> {
  CheckoutPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  // List<BeamPage> buildPages(BuildContext context, BeamState state) {
  //   dynamic datas = data;
  //   List<Cartitems> cartitems = [];
  //   int finalamount = 0;
  //   int shippingcost = 0;
  //   int deliveryfee = 0;
  //   String carttype = "";
  //   String storeid = "";
  //   CoupanModel coupanmodel = CoupanModel.empty();
  //   print("is datas 112  ${datas}");
  //   // && datas['addresslist'] == null || datas == {}
  //   if (datas != null) {
  //     print("HR CHECK 01");
  //     cartitems = datas['cartitems'];
  //     coupanmodel = datas['coupanmodel'] ?? CoupanModel.empty();
  //     print("HR CHECK 01.05");
  //     perfs!.setString('deliveryfee', datas['deliveryfee'].toString());
  //     perfs!.setString('finalamount', datas['finalamount'].toString());
  //     perfs!.setString('shippingcost', datas['shippingcost'].toString());
  //     perfs!.setString('carttypecheckout', datas['carttype'].toString());
  //     perfs!.setString('storeidcheckout', datas['storeid'].toString());
  //     perfs!.setString(
  //         'cartitemss',
  //         jsonEncode(cartitems.map((e) {
  //           return e.toJson();
  //         }).toList()));
  //     print("HR CHECK  1.3");
  //     // if (datas['coupanmodel'] != null) {
  //     //   perfs!.setString('coupanmodel', jsonEncode(coupanmodel.toNewJson()));
  //     // }

  //     print("HR CHECK  1.5");

  //     print("HR CHECK 02");
  //   } else {
  //     String deliveryfees = perfs!.getString('deliveryfee') ?? "";
  //     String finalamounts = perfs!.getString('finalamount') ?? "";
  //     carttype = perfs!.getString('carttype') ?? "";
  //     storeid = perfs!.getString('storeid') ?? "";
  //     String shippingcosts = perfs!.getString(
  //           'shippingcost',
  //         ) ??
  //         "";
  //     var cartitemss = perfs!.getString(
  //           'cartitemss',
  //         ) ??
  //         "";
  //     // coupanmodel = CoupanModel.fromJson(
  //     //     jsonDecode(perfs!.getString('coupanmodel') ?? '{}'));
  //     print("HR CHECK 03");
  //     print("HR CHECK 03 ${deliveryfees}");

  //     finalamount = int.parse(finalamounts);
  //     shippingcost = int.parse(shippingcosts);
  //     deliveryfee = int.parse(deliveryfees);
  //     print("detoo $data");
  //     List<dynamic> product111 = jsonDecode(cartitemss);
  //     print("detoo $data");
  //     product111.forEach(
  //       (element) {
  //         print("every element $element");
  //         Cartitems cartitem = Cartitems.fromJson(element);
  //         cartitems.add(cartitem);
  //       },
  //     );
  //     print("product done :: ${cartitems}");
  //     print("HR CHECK 04");
  //   }
  //   return [
  //     BeamPage(
  //         key: ValueKey('/CheckoutPage'),
  //         title: "CheckoutPage",
  //         child: CheckoutPage(
  //           deliveryfee: datas != null ? datas['deliveryfee'] : deliveryfee,
  //           finalamount: datas != null ? datas['finalamount'] : finalamount,
  //           shippingcost: datas != null ? datas['shippingcost'] : shippingcost,
  //           cartitems: datas != null ? datas['cartitems'] : cartitems,
  //           // carttype: datas != null ? datas['carttype'] : carttype,
  //           // storeid: datas != null ? datas['storeid'] : storeid,
  //           // copunmodel: datas != null ? datas['coupanmodel'] : coupanmodel,
  //         ))
  //   ];
  // }
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    List<Cartitems> cartitems = [];
    int finalamount = 0;
    int shippingcost = 0;
    int deliveryfee = 0;
    double subtotal = 0.0;
    double discountsubtotal = 0.0;
    CoupanModel coupanmodel = CoupanModel.empty();
    // && datas['addresslist'] == null || datas == {}
    if (datas != null) {
      cartitems = datas['cartitems'];
      coupanmodel = datas['coupanmodel'] ?? CoupanModel.empty();
      perfs!.setString('deliveryfee', datas['deliveryfee'].toString());
      perfs!.setString('finalamount', datas['finalamount'].toString());
      perfs!.setString('shippingcost', datas['shippingcost'].toString());
      perfs!.setString('carttypecheckout', datas['carttype'].toString());
      perfs!.setString('storeidcheckout', datas['storeid'].toString());
      perfs!.setDouble('subtotal', datas['subtotal']);
      perfs!.setDouble('discountsubtotal', datas['discountsubtotal']);
      perfs!.setString(
          'cartitemss',
          jsonEncode(cartitems.map((e) {
            return e.toJson();
          }).toList()));
      if (datas['coupanmodel'] != null) {
        perfs!.setString('coupanmodel', jsonEncode(coupanmodel.toNewJson()));
      }


    } else {
      String deliveryfees = perfs!.getString('deliveryfee') ?? "";
      String finalamounts = perfs!.getString('finalamount') ?? "";
      subtotal = perfs!.getDouble('subtotal') ?? 0.0;
      discountsubtotal = perfs!.getDouble('discountsubtotal') ?? 0.0;
      String shippingcosts = perfs!.getString(
            'shippingcost',
          ) ??
          "";
      var cartitemss = perfs!.getString(
            'cartitemss',
          ) ??
          "";

      coupanmodel = CoupanModel.fromJson(
          jsonDecode(perfs!.getString('coupanmodel') ?? '{}'));

      finalamount = int.parse(finalamounts);
      shippingcost = int.parse(shippingcosts);
      deliveryfee = int.parse(deliveryfees);
      List<dynamic> product111 = jsonDecode(cartitemss);
      for (var element in product111) {
          Cartitems cartitem = Cartitems.fromJson(element);
          cartitems.add(cartitem);
        }
    }
    return [
      BeamPage(
          key: ValueKey('/CheckoutPage'),
          title: "CheckoutPage",
          child: CheckoutPage(
            deliveryfee: datas != null ? datas['deliveryfee'] : deliveryfee,
            finalamount: datas != null ? datas['finalamount'] : finalamount,
            shippingcost: datas != null ? datas['shippingcost'] : shippingcost,
            cartitems: datas != null ? datas['cartitems'] : cartitems,
            copunmodel: datas != null ? datas['coupanmodel'] : coupanmodel,
            subtotal: datas != null ? datas['subtotal'] : subtotal,
            discountsubtotal:
                datas != null ? datas['discountsubtotal'] : discountsubtotal,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/CheckoutPage'];
}

class CategoryViewallPageLocation extends BeamLocation<BeamState> {
  CategoryViewallPageLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    List<CategoryModel> categoryModellist = [];

    if (datas != null && datas['visitlist'] != null) {
      categoryModellist = datas['visitlist'];

      perfs!.setString(
          'categoryviewall',
          jsonEncode(categoryModellist.map((e) {
            return e.toJson();
          }).toList()));
    } else {
      var shippingcost = perfs!.getString(
            'categoryviewall',
          ) ??
          "";

      List<dynamic> product111 = jsonDecode(shippingcost);
      for (var element in product111) {
          CategoryModel categoryModel =
              CategoryModel.fromJson(Map<String, dynamic>.from(element));
          categoryModellist.add(categoryModel);
        }
    }
    return [
      BeamPage(
          key: ValueKey('/CategoryViewallPage'),
          title: "CategoryViewallPage",
          child: CategoryViewallPage(
            visitlist: (datas != null && datas['visitlist'] != null)
                ? datas['visitlist']
                : categoryModellist,
          ))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/CategoryViewallPage'];
}

class AllProductsLocation extends BeamLocation<BeamState> {
  AllProductsLocation(RouteInformation super.delegate, BeamParameters super.data);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    dynamic datas = data;
    return [
      BeamPage(
        key: ValueKey('/AllProducts'),
        title: "AllProducts",
        child: AllProductsPage(
          heading: (datas != null && datas['heading'] != null)
              ? datas['heading']
              : null,
        ),
      )
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/AllProducts'];
}
