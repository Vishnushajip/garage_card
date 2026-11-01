import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/location/geohash_helper.dart';
import 'package:garage_card/core/pagination/paginated_result.dart';

import '../models/garage_model.dart';
import '../models/garage_search_result_model.dart';
import '../models/garage_service_model.dart';
import '../models/review_model.dart';
import '../pricing/smart_pricing_engine.dart';
import 'garage_repository_store.dart';

mixin GarageDataRepository on GarageRepositoryStore {
  Future<void> seedInitialFirestoreDataIfNeeded() async {}

  Future<List<GarageModel>> getNearbyGarages({
    required double latitude,
    required double longitude,
    double radiusKm = AppConstants.defaultNearbyRadiusKm,
    String? searchQuery,
    int limit = 20,
  }) async {
    List<GarageModel> source = [];

    if (FirebaseConfig.isInitialized) {
      try {
        final collection = FirebaseFirestore.instance.collection('garages');
        final snapshot = await collection
            .limit(50)
            .get()
            .timeout(const Duration(seconds: 4));
        source = snapshot.docs
            .map((d) => GarageModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_NEARBY_GARAGES_ERROR: $e');
        return [];
      }
    } else {
      source = garages;
    }

    final list = source.where((g) {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchName = g.name.toLowerCase().contains(query);
        final matchCity = g.city.toLowerCase().contains(query);
        final matchAddress = g.address.toLowerCase().contains(query);
        if (!matchName && !matchCity && !matchAddress) return false;
      }
      final dist = GeohashHelper.calculateDistanceKm(
        lat1: latitude,
        lon1: longitude,
        lat2: g.latitude,
        lon2: g.longitude,
      );
      return dist <= radiusKm * 2;
    }).toList();

    list.sort((a, b) {
      final distA = GeohashHelper.calculateDistanceKm(
        lat1: latitude,
        lon1: longitude,
        lat2: a.latitude,
        lon2: a.longitude,
      );
      final distB = GeohashHelper.calculateDistanceKm(
        lat1: latitude,
        lon1: longitude,
        lat2: b.latitude,
        lon2: b.longitude,
      );
      return distA.compareTo(distB);
    });

    return list.take(limit).toList();
  }

  Future<GarageModel?> getGarageDetails(String garageId) async {
    if (FirebaseConfig.isInitialized) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .get()
            .timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          return GarageModel.fromFirestore(doc.data()!, doc.id);
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    return garages.cast<GarageModel?>().firstWhere(
      (g) => g?.id == garageId,
      orElse: () => null,
    );
  }

  Future<GarageModel?> getGarageByOwnerUid(String ownerUid) async {
    if (FirebaseConfig.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collection('garages')
            .where('ownerUid', isEqualTo: ownerUid)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 4));
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          return GarageModel.fromFirestore(doc.data(), doc.id);
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    return garages.cast<GarageModel?>().firstWhere(
      (g) => g?.ownerUid == ownerUid,
      orElse: () => null,
    );
  }

  Future<void> updateGarageProfile(GarageModel updated) async {
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(updated.id)
            .set(updated.toFirestore(), SetOptions(merge: true));
      } catch (_) {}
    }

    final index = garages.indexWhere((g) => g.id == updated.id);
    if (index >= 0) {
      garages[index] = updated;
    } else {
      garages.add(updated);
    }
  }

  Future<List<GarageServiceModel>> getGarageServices(String garageId) async {
    if (garageId.isEmpty) return [];
    if (FirebaseConfig.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .get()
            .timeout(const Duration(seconds: 4));
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((d) => GarageServiceModel.fromFirestore(d.data(), d.id))
              .toList();
        }

        final catSnap = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceCatalog')
            .get()
            .timeout(const Duration(seconds: 4));
        if (catSnap.docs.isNotEmpty) {
          return catSnap.docs
              .map((d) => GarageServiceModel.fromFirestore(d.data(), d.id))
              .toList();
        }

        return [];
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_SERVICES_ERROR: $e');
        return [];
      }
    }
    return services.where((s) => s.garageId == garageId).toList();
  }

  Future<void> saveGarageService(
    String garageId,
    GarageServiceModel service,
  ) async {
    final idx = services.indexWhere((s) => s.id == service.id);
    if (idx >= 0) {
      services[idx] = service;
    } else {
      services.add(service);
    }
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .doc(service.id)
            .set(service.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_SAVE_SERVICE_ERROR: $e');
      }
    }
  }

  Future<void> toggleServiceActive(
    String garageId,
    String serviceId,
    bool isActive,
  ) async {
    final idx = services.indexWhere((s) => s.id == serviceId);
    if (idx >= 0) {
      services[idx] = services[idx].copyWith(isActive: isActive);
    }
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .doc(serviceId)
            .update({'isActive': isActive});
      } catch (e) {
        debugPrint('GARAGE_REPO_TOGGLE_SERVICE_ERROR: $e');
      }
    }
  }

  Future<void> deleteGarageService(String garageId, String serviceId) async {
    services.removeWhere((s) => s.id == serviceId);
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('services')
            .doc(serviceId)
            .delete();
      } catch (e) {
        debugPrint('GARAGE_REPO_DELETE_SERVICE_ERROR: $e');
      }
    }
  }

  Future<List<GarageSearchResultModel>> searchGaragesAndServices({
    String? query,
    String? category,
    String? vehicleType,
    double? maxDistanceKm,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'nearest',
    double userLat = 9.9674,
    double userLon = 76.2891,
    int limit = 30,
  }) async {
    final nearbyGarages = await getNearbyGarages(
      latitude: userLat,
      longitude: userLon,
      radiusKm: maxDistanceKm ?? 50.0,
      limit: 50,
    );

    final results = <GarageSearchResultModel>[];
    final q = query?.trim().toLowerCase() ?? '';
    final cat = (category != null && category.toLowerCase() != 'all')
        ? category.toLowerCase()
        : null;
    final veh = (vehicleType != null && vehicleType.toLowerCase() != 'all')
        ? vehicleType.toLowerCase()
        : null;

    for (final garage in nearbyGarages) {
      final distance = GeohashHelper.calculateDistanceKm(
        lat1: userLat,
        lon1: userLon,
        lat2: garage.latitude,
        lon2: garage.longitude,
      );

      if (maxDistanceKm != null && distance > maxDistanceKm) {
        continue;
      }

      final garageServices = await getGarageServices(garage.id);
      final activeServices = garageServices.where((s) => s.isActive).toList();

      final garageTextMatch =
          q.isEmpty ||
          garage.name.toLowerCase().contains(q) ||
          garage.city.toLowerCase().contains(q) ||
          garage.address.toLowerCase().contains(q);

      final matchingServices = activeServices.where((s) {
        if (cat != null && s.category.toLowerCase() != cat) {
          return false;
        }

        if (veh != null && !s.supportsVehicle(veh)) {
          return false;
        }

        final evaluated = SmartPricingEngine.evaluate(
          service: s,
          vehicleType: veh,
          currencyCode: garage.currencyCode,
        );

        if (minPrice != null &&
            (evaluated.amount == null || evaluated.amount! < minPrice)) {
          return false;
        }
        if (maxPrice != null &&
            (evaluated.amount == null || evaluated.amount! > maxPrice)) {
          return false;
        }

        if (q.isNotEmpty && !garageTextMatch) {
          final sName = s.name.toLowerCase();
          final sDesc = s.description.toLowerCase();
          final sCat = s.category.toLowerCase();
          if (!sName.contains(q) && !sDesc.contains(q) && !sCat.contains(q)) {
            return false;
          }
        }

        return true;
      }).toList();

      if (q.isNotEmpty && !garageTextMatch && matchingServices.isEmpty) {
        continue;
      }

      if (cat != null && matchingServices.isEmpty) {
        continue;
      }

      if (veh != null && matchingServices.isEmpty) {
        continue;
      }

      if ((minPrice != null || maxPrice != null) && matchingServices.isEmpty) {
        continue;
      }

      GarageServiceModel? topService;
      EvaluatedPrice? topPrice;

      if (matchingServices.isNotEmpty) {
        topService = matchingServices.first;
        topPrice = SmartPricingEngine.evaluate(
          service: topService,
          vehicleType: veh,
          currencyCode: garage.currencyCode,
        );
      } else if (activeServices.isNotEmpty) {
        topService = activeServices.first;
        topPrice = SmartPricingEngine.evaluate(
          service: topService,
          vehicleType: veh,
          currencyCode: garage.currencyCode,
        );
      }

      results.add(
        GarageSearchResultModel(
          garage: garage,
          distanceKm: distance,
          matchedService: topService,
          evaluatedPrice: topPrice,
        ),
      );
    }

    if (sortBy == 'nearest') {
      results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (sortBy == 'price_asc') {
      results.sort((a, b) {
        final pa = a.evaluatedPrice?.amount ?? double.infinity;
        final pb = b.evaluatedPrice?.amount ?? double.infinity;
        return pa.compareTo(pb);
      });
    } else if (sortBy == 'price_desc') {
      results.sort((a, b) {
        final pa = a.evaluatedPrice?.amount ?? -1.0;
        final pb = b.evaluatedPrice?.amount ?? -1.0;
        return pb.compareTo(pa);
      });
    } else if (sortBy == 'rating') {
      results.sort((a, b) => b.garage.rating.compareTo(a.garage.rating));
    }

    return results.take(limit).toList();
  }

  Future<void> submitGarageReview(ReviewModel review) async {
    reviews.insert(0, review);
    final garageIdx = garages.indexWhere((g) => g.id == review.garageId);
    if (garageIdx >= 0) {
      final g = garages[garageIdx];
      final newCount = g.reviewCount + 1;
      final newRating = ((g.rating * g.reviewCount) + review.rating) / newCount;
      garages[garageIdx] = g.copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: newCount,
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final garageRef = FirebaseFirestore.instance
            .collection('garages')
            .doc(review.garageId);
        final reviewRef = garageRef.collection('reviews').doc(review.id);

        await FirebaseFirestore.instance.runTransaction((tx) async {
          final gSnap = await tx.get(garageRef);
          if (gSnap.exists) {
            final data = gSnap.data()!;
            final currentCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
            final currentRating = (data['rating'] as num?)?.toDouble() ?? 4.8;
            final newCount = currentCount + 1;
            final newRating =
                ((currentRating * currentCount) + review.rating) / newCount;

            tx.set(reviewRef, review.toFirestore());
            tx.update(garageRef, {
              'rating': double.parse(newRating.toStringAsFixed(1)),
              'reviewCount': newCount,
            });
          } else {
            tx.set(reviewRef, review.toFirestore());
          }
        });
      } catch (_) {}
    }
  }

  Future<PaginatedResult<ReviewModel>> getGarageReviewsPaginated(
    String garageId, {
    int limit = 10,
    Object? lastDocument,
  }) async {
    if (FirebaseConfig.isInitialized) {
      try {
        var query = FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .limit(limit);

        if (lastDocument is DocumentSnapshot) {
          query = query.startAfterDocument(lastDocument);
        }

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final items = snap.docs
              .map((d) => ReviewModel.fromFirestore(d.data(), d.id))
              .toList();
          return PaginatedResult(
            items: items,
            lastDocument: snap.docs.last,
            hasMore: snap.docs.length >= limit,
          );
        }
      } catch (_) {}
    }

    final local = reviews.where((r) => r.garageId == garageId).toList();
    return PaginatedResult(items: local, hasMore: false);
  }
}
