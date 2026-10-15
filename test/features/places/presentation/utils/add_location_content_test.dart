import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/places/domain/entity/place_entity.dart';
import 'package:pulse/features/places/presentation/cubit/add_location_state.dart';
import 'package:pulse/features/places/presentation/utils/enums/add_location_content.dart';
import 'package:pulse/features/places/presentation/utils/enums/add_location_status.dart';
import 'package:pulse/features/places/presentation/utils/enums/location_search_status.dart';

void main() {
  const ready = AddLocationState(status: AddLocationStatus.ready);

  test('nothing is known before the permission is read', () {
    expect(
      AddLocationContent.resolve(const AddLocationState()),
      AddLocationContent.loading,
    );
  });

  test('the primer comes before everything else', () {
    expect(
      AddLocationContent.resolve(
        ready.copyWith(showPrimer: true, query: 'kar'),
      ),
      AddLocationContent.primer,
    );
  });

  test('one character is not a search yet', () {
    expect(
      AddLocationContent.resolve(ready.copyWith(query: 'k')),
      AddLocationContent.home,
    );
  });

  test('two characters search, while loading and with results', () {
    final searching = ready.copyWith(
      query: 'ka',
      searchStatus: LocationSearchStatus.loading,
    );
    expect(AddLocationContent.resolve(searching), AddLocationContent.search);
    expect(
      AddLocationContent.resolve(
        searching.copyWith(
          searchStatus: LocationSearchStatus.ready,
          results: const [PlaceEntity(name: 'Karnak')],
        ),
      ),
      AddLocationContent.search,
    );
  });

  test('an answer with nothing in it is the no results panel', () {
    expect(
      AddLocationContent.resolve(
        ready.copyWith(query: 'zzz', searchStatus: LocationSearchStatus.ready),
      ),
      AddLocationContent.noResults,
    );
  });

  test('a failed search stays on the search panel', () {
    expect(
      AddLocationContent.resolve(
        ready.copyWith(query: 'zzz', searchStatus: LocationSearchStatus.failed),
      ),
      AddLocationContent.search,
    );
  });
}
