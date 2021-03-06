import 'dart:async';

import 'package:angular/src/core/di.dart' show Injectable;
import 'package:angular/src/core/reflection/reflection.dart' show reflector;
import 'package:angular/src/facade/exceptions.dart' show BaseException;

import 'component_factory.dart' show ComponentFactory;

/// Low-level service for loading [ComponentFactory]s, which
/// can later be used to create and render a Component instance.
abstract class ComponentResolver {
  Future<ComponentFactory> resolveComponent(Type componentType);

  void clearCache();
}

@Injectable()
class ReflectorComponentResolver implements ComponentResolver {
  Future<ComponentFactory> resolveComponent(Type componentType) {
    var metadatas = reflector.annotations(componentType);
    var componentFactory = metadatas
        .firstWhere((type) => type is ComponentFactory, orElse: () => null);
    if (componentFactory == null) {
      throw new BaseException('No precompiled component $componentType found');
    }
    return new Future<ComponentFactory>.value(componentFactory);
  }

  @override
  void clearCache() {}
}
