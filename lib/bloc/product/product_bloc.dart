import 'package:bloc/bloc.dart';
import '../../models/product_model.dart';
import '../../repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;
  List<ProductModel> _cachedProducts = [];

  ProductBloc({required ProductRepository repository})
      : _repository = repository,
        super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearch);
    on<LoadProductDetailEvent>(_onLoadDetail);
    on<AddProductEvent>(_onAddProduct);
    on<EditProductEvent>(_onEditProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
      LoadProductsEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _repository.getAllProducts();
      _cachedProducts = products;
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearch(
      SearchProductsEvent event, Emitter<ProductState> emit) async {
    try {
      final query = event.query.toLowerCase().trim();
      if (query.isEmpty) {
        final all = await _repository.getAllProducts();
        emit(ProductLoaded(all));
        return;
      }
      final products = await _repository.searchProducts(query);
      if (products.isNotEmpty) {
        emit(ProductLoaded(products));
      } else {
        final all = await _repository.getAllProducts();
        final filtered = all.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query);
        }).toList();
        emit(ProductLoaded(filtered));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
      LoadProductDetailEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await _repository.getProduct(event.id);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
      AddProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductAdding());
    try {
      final imageUrl =
          await _repository.uploadProductImage(event.imageBytes);
      await _repository.addProduct({
        'name': event.name,
        'sub': event.description,
        'price': event.price,
        'category': event.category,
        'image': imageUrl,
        'phone': event.phone,
        'fresh': event.fresh,
        'organic': event.organic,
        'farm': event.farm,
        'userId': event.userId,
      });
      emit(ProductAddSuccess());
      final products = await _repository.getAllProducts();
      _cachedProducts = products;
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductAddError(e.toString()));
      emit(ProductLoaded(_cachedProducts));
    }
  }

  Future<void> _onEditProduct(
      EditProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductAdding());
    try {
      final imageUrl = event.newImageBytes != null
          ? await _repository.uploadProductImage(event.newImageBytes!)
          : event.currentImageUrl;
      await _repository.updateProduct(event.productId, {
        'name': event.name,
        'sub': event.description,
        'price': event.price,
        'category': event.category,
        'image': imageUrl,
        'phone': event.phone,
        'fresh': event.fresh,
        'organic': event.organic,
        'farm': event.farm,
      });
      emit(ProductEditSuccess());
      final products = await _repository.getAllProducts();
      _cachedProducts = products;
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductAddError(e.toString()));
      emit(ProductLoaded(_cachedProducts));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductAdding());
    try {
      await _repository.deleteProduct(event.productId);
      emit(ProductDeleteSuccess());
      final products = await _repository.getAllProducts();
      _cachedProducts = products;
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductAddError(e.toString()));
      emit(ProductLoaded(_cachedProducts));
    }
  }
}
