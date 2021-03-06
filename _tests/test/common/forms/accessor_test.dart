@Tags(const ['codegen'])
@TestOn('browser')
library angular2.test.common.forms.accessor_test;

import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';
import 'package:angular/angular.dart';
import 'package:angular/src/common/forms/directives/control_value_accessor.dart';

void main() {
  group('accessor test', () {
    tearDown(disposeAnyRunningTest);

    test('should have error on invalid input', () async {
      var testBed = new NgTestBed<AccessorTestComponent>();
      NgTestFixture<AccessorTestComponent> fixture = await testBed.create();

      await fixture.update((AccessorTestComponent c) {
        (c.model.valueAccessor as IntValueAccessor).onChange('aaa');

        expect(c.model.value, null);
        expect(c.model.control.rawValue, 'aaa');
        expect(c.model.control.errors.values.single, 'aaa');
        expect(c.model.control.errors.keys.single, 'int-error');
      });
    });

    test('shouldn\'t have error on valid input', () async {
      var testBed = new NgTestBed<AccessorTestComponent>();
      NgTestFixture<AccessorTestComponent> fixture = await testBed.create();

      await fixture.update((AccessorTestComponent c) {
        (c.model.valueAccessor as IntValueAccessor).onChange('5');

        expect(c.value, 5);
        expect(c.model.value, 5);
        expect(c.model.control.rawValue, '5');
        expect(c.model.control.errors, null,
            reason: 'Valid value should not have an error');
      });
    });
  });
}

@Component(
    selector: 'accessor-test',
    template: '<input type="text" integer [(ngModel)]="value">',
    directives: const [IntValueAccessor, NgModel])
class AccessorTestComponent {
  @ViewChild(NgModel)
  NgModel model;
  int value = 1;
}

typedef dynamic ChangeFunctionSimple(value);

@Directive(selector: "input[integer]", host: const {
  "(input)": "onChange(\$event.target.value)",
  "(blur)": "touchHandler()"
}, providers: const [
  const Provider(NG_VALUE_ACCESSOR, useExisting: IntValueAccessor, multi: true),
  const Provider(NG_VALIDATORS, useExisting: IntValueAccessor, multi: true)
])
class IntValueAccessor implements ControlValueAccessor, Validator {
  HtmlElement _elementRef;
  ChangeFunctionSimple onChange = (_) {};

  void touchHandler() {
    onTouched();
  }

  TouchFunction onTouched = () {};
  IntValueAccessor(this._elementRef);
  @override
  void writeValue(dynamic value) {
    var normalizedValue = value.toString() ?? '';
    js_util.setProperty(_elementRef, 'value', normalizedValue);
  }

  @override
  void registerOnChange(ChangeFunction fn) {
    this.onChange = (value) {
      var result;
      try {
        result = int.parse(value);
      } on FormatException {
        // Catching error will keep the result as null.
      }
      fn(result, rawValue: value);
    };
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    this.onTouched = fn;
  }

  @override
  Map<String, dynamic> validate(AbstractControl c) {
    if (c is Control && c.value == null && c.rawValue != null) {
      // We couldn't parse the input there must have been an error
      return {'int-error': c.rawValue};
    }
    return null;
  }
}
