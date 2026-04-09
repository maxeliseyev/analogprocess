Коротко: ты сломал **safe areas / layout lifecycle**, потому что при кастомном `Info.plist` почти всегда забывают **обязательные системные ключи**. В итоге UIKit считает, что у приложения «нестандартная конфигурация экрана».

По симптомам на скрине (контент уезжает под навбар / статусбар) — это **не Auto Layout**, а именно конфигурация приложения.

---

## Что проверить и починить (по порядку)

### 1. **UIApplicationSceneManifest — ОБЯЗАТЕЛЬНО**

Если ты создавал `Info.plist` с нуля, скорее всего его нет.

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

❗ Без этого:

* ломаются safe area
* некорректные bounds
* навбар и статусбар ведут себя странно

---

### 2. **UIViewControllerBasedStatusBarAppearance**

Если его нет — UIKit считает, что статусбар «глобальный».

```xml
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>
```

Иначе контент легко заезжает под статусбар.

---

### 3. **UISupportedInterfaceOrientations (iPhone)**

Без этого iOS может считать layout «неполным».

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

---

### 4. **UIRequiresFullScreen**

Иногда без него на iPhone появляются странные размеры (особенно на Plus / Max).

```xml
<key>UIRequiresFullScreen</key>
<true/>
```

---

### 5. Проверь, что ты **НЕ удалил**:

```xml
<key>UILaunchScreen</key>
<dict/>
```

Даже пустой. Без launch screen UIKit иногда криво инициализирует окно.

---

## Быстрый способ проверить

1. Создай **новый пустой iOS-проект**
2. Сравни его `Info.plist` со своим
3. Всё, что есть в новом — должно быть и у тебя (кроме лишнего)

---

## Почему это произошло

Кастомный `Info.plist` ≠ минимальный `Info.plist`.

UIKit:

* читает его **до** создания window
* на основе plist решает, **как считать размеры экрана**
* если ключей нет — включает legacy-поведение

---
