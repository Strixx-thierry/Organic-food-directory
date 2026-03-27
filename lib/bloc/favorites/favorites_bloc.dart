import 'package:bloc/bloc.dart';
import '../../models/product_model.dart';
import '../../repositories/favorites_repository.dart';
import '../../repositories/product_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _favRepo;
  final ProductRepository _productRepo;

  FavoritesBloc({
    required FavoritesRepository favRepo,
    required ProductRepository productRepo,
  })  : _favRepo = favRepo,
        _productRepo = productRepo,
        super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    // Don't auto-load here — FavoritesPage.initState() handles this
    // so we don't hammer Firestore before the user is even logged in.
  }

  Future<void> _onLoadFavorites(LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final ids = await _favRepo.getFavorites();
      // Fetch all products in parallel instead of one at a time
      final results = await Future.wait(
        ids.map((id) async {
          try {
            return await _productRepo.getProduct(id);
          } catch (_) {
            return null;
          }
        }),
      );
      final favProducts = results.whereType<ProductModel>().toList();
      emit(FavoritesLoaded(favProducts));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<FavoritesState> emit) async {
    try {
      await _favRepo.toggleFavorite(event.productId);
      // Reload favorites after toggle
      add(LoadFavoritesEvent());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}