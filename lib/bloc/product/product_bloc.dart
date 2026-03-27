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
              p.sub.toLowerCase().contains(query) ||
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
        'sub': event.sub,
        'price': event.price,
        'category': event.category,
        'image': imageUrl,
        'phone': event.phone,
        'fresh': event.fresh,
        'organic': event.organic,
        'farm': event.farm,
      });
      emit(ProductAddSuccess());
      // Reload so the home page featured grid stays fresh.
      final products = await _repository.getAllProducts();
      _cachedProducts = products;
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductAddError(e.toString()));
      // Restore the last known list so the home page doesn't go blank.
      emit(ProductLoaded(_cachedProducts));
    }
  }
}
