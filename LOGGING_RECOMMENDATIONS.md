# Рекомендации по расширению логирования

## Текущее состояние

✅ **Уже покрыто логированием:**
- `UnifiedTimerViewModel` - детальное логирование работы таймера
- `SwiftDataPersistence` - инициализация и восстановление БД
- `AutoSyncService` - синхронизация и сетевые операции
- `GitHubDataService` - загрузка данных с GitHub (частично)
- `GitHubAgitationService` - обновление режимов агитации
- `AgitationRuleEngine` - инициализация пресетов
- `CoachMarksService` - отображение подсказок
- `MainTabView` - навигация

## Рекомендуемые места для добавления логирования

### 1. ViewModels (Высокий приоритет)

#### `DevelopmentSetupViewModel`
**Зачем:** Это ключевой экран настройки проявки, где пользователи выбирают пленку, проявитель и параметры. Логирование поможет понять, как пользователи используют приложение и где возникают проблемы.

**Что логировать:**
```swift
// Категория: UI
- Выбор пленки: "Film selected: \(film.name)"
- Выбор проявителя: "Developer selected: \(developer.name)"
- Изменение ISO: "ISO changed: \(iso)"
- Изменение температуры: "Temperature changed: \(temperature)"
- Автоматический расчет времени: "Time calculated: \(calculatedTime)s"
- Переход к калькулятору: "Navigate to calculator"
- Переход к таймеру: "Navigate to timer with time: \(time)"

// Категория: General (ошибки)
- Ошибки расчета: "Failed to calculate time: \(error)"
- Отсутствие данных: "No development time found for combination"
```

#### `CalculatorViewModel`
**Зачем:** Калькулятор пуш/пулл процесса - критическая функция. Логирование поможет отладить проблемы с расчетами и валидацией.

**Что логировать:**
```swift
// Категория: UI
- Начало расчета: "Calculate time - minutes: \(minutes), seconds: \(seconds), coefficient: \(coefficient)"
- Результат расчета: "Calculation result - push steps: \(pushSteps), results count: \(pushResults.count)"
- Применение температурного коэффициента: "Temperature multiplier applied: \(temperatureMultiplier)"
- Запуск таймера: "Start timer for step: \(label), time: \(minutes):\(seconds)"
- Сохранение в журнал: "Save calculation result to journal"

// Категория: General (валидация)
- Невалидный ввод: "Invalid input - minutes: \(minutes), seconds: \(seconds), coefficient: \(coefficient)"
```

#### `StagingViewModel`
**Зачем:** Управление последовательностью стадий - сложная логика. Логирование поможет отследить проблемы с загрузкой пресетов и манипуляциями со стадиями.

**Что логировать:**
```swift
// Категория: UI
- Загрузка пресета: "Preset loaded: \(preset.name), stages count: \(preset.stages.count)"
- Добавление стадии: "Stage added: \(stage.name)"
- Удаление стадии: "Stage removed: \(stage.name)"
- Перестановка стадий: "Stages reordered"
- Сохранение состояния: "Selected stages saved, count: \(selectedStages.count)"
- Запуск последовательности: "Starting staging sequence with \(selectedStages.count) stages"

// Категория: Sync
- Обновление доступных пресетов: "Available presets updated, count: \(availablePresets.count)"
```

#### `CreateRecordViewModel`
**Зачем:** Создание записей в журнале - важная функция для отслеживания результатов пользователей.

**Что логировать:**
```swift
// Категория: Persistence
- Начало создания: "Creating new journal record"
- Сохранение записи: "Record saved - film: \(filmName), developer: \(developerName), time: \(minutes):\(seconds)"
- Предзаполнение формы: "Form prefilled from record: \(record.id)"

// Категория: General (валидация)
- Ошибки валидации: "Validation failed: \(validationErrors)"
- Успешная валидация: "Validation passed"
```

#### `JournalViewModel`
**Зачем:** Просмотр и управление журналом записей.

**Что логировать:**
```swift
// Категория: Persistence
- Удаление записи: "Record deleted: \(record.id)"
- Загрузка записей: "Journal records loaded, count: \(records.count)"

// Категория: General
- Ошибки: "Error in journal: \(errorMessage)"
```

### 2. Services (Средний приоритет)

#### `SwiftDataService`
**Зачем:** Центральный сервис для работы с данными. Частично логируется, но нужно расширить.

**Что добавить:**
```swift
// Категория: Persistence
- Операции вставки/обновления/удаления данных
- Результаты запросов к БД
- Проблемы с загрузкой JSON файлов
- Синхронизация данных с GitHub

// Категория: Sync
- Начало синхронизации: "Starting data sync from GitHub"
- Завершение синхронизации: "Sync completed - films: \(count), developers: \(count), ..."
- Конфликты при слиянии: "Merge conflict detected"
```

#### `PresetService`
**Зачем:** Управление пресетами процессов.

**Что логировать:**
```swift
// Категория: Sync
- Загрузка пресетов: "Loading presets from database"
- Обновление пресетов: "Presets updated, count: \(presets.count)"
- Создание дефолтных пресетов: "Creating default presets"

// Категория: General
- Ошибки загрузки: "Failed to load presets: \(error)"
```

#### `DevelopmentCalculator`
**Зачем:** Математические расчеты времени проявки.

**Что логировать:**
```swift
// Категория: General
- Расчет времени: "Calculate time - base: \(minutes):\(seconds), coefficient: \(coefficient)"
- Результат расчета: "Calculated results, steps: \(results.count)"
- Граничные случаи: "Edge case detected - time too short/long"
```

#### `ValidationManager`
**Зачем:** Валидация пользовательского ввода.

**Что логировать:**
```swift
// Категория: General
- Ошибки валидации: "Validation error - field: \(fieldName), error: \(error)"
- Успешная валидация: "Validation passed for field: \(fieldName)"
```

### 3. Критические операции пользователя (Высокий приоритет)

#### Переходы между экранами
**Где:** В различных View

**Что логировать:**
```swift
// Категория: Navigation
- "Navigated to DevelopmentSetup"
- "Navigated to Calculator"
- "Navigated to Timer with mode: \(mode)"
- "Navigated to Journal"
- "Opened record detail: \(record.id)"
```

#### Действия с данными
**Где:** В ViewModels при взаимодействии с базой

**Что логировать:**
```swift
// Категория: Persistence
- "Film created/updated/deleted: \(film.name)"
- "Developer created/updated/deleted: \(developer.name)"
- "Journal record created/updated/deleted"
- "Preset applied: \(preset.name)"
```

### 4. Производительность (Средний приоритет)

#### Долгие операции
**Где:** В сервисах и ViewModels

**Что логировать:**
```swift
// Измерение времени выполнения
let startTime = Date()
// ... операция ...
let duration = Date().timeIntervalSince(startTime)
if duration > 0.5 {
    Logger.log(.error, "Slow operation detected: \(duration)s")
}
```

**Примеры операций для мониторинга:**
- Загрузка данных из БД
- Синхронизация с GitHub
- Расчет сложных формул
- Парсинг JSON

### 5. Ошибки и исключительные ситуации (Высокий приоритет)

**Везде, где есть try-catch блоки:**
```swift
do {
    // операция
} catch {
    Logger.log(.error, "Operation failed: \(error.localizedDescription)")
    throw error
}
```

**Особенно важно в:**
- Работе с сетью
- Работе с БД
- Парсинге JSON
- Валидации пользовательского ввода

## Рекомендуемые категории для новых логов

### Добавить новую категорию: `Calculation`
```swift
public static let calculation = OSLog(subsystem: subsystem, category: "Calculation")

public static func logCalculation(_ message: String, type: OSLogType = .default) {
    let timestamp = Date()
    os_log("[%{public}@] %{public}@", log: calculation, type: type, timestamp.description, message)

    #if DEBUG
    print("[Calculation] [\(timestamp)] \(message)")
    #endif
}
```

**Использование:**
- Расчеты времени проявки
- Применение коэффициентов
- Расчеты пуш/пулл процесса
- Температурные поправки

### Добавить новую категорию: `UserAction`
```swift
public static let userAction = OSLog(subsystem: subsystem, category: "UserAction")

public static func logUserAction(_ message: String, type: OSLogType = .default) {
    let timestamp = Date()
    os_log("[%{public}@] %{public}@", log: userAction, type: type, timestamp.description, message)

    #if DEBUG
    print("[UserAction] [\(timestamp)] \(message)")
    #endif
}
```

**Использование:**
- Выбор параметров
- Нажатия кнопок
- Навигация
- Сохранение данных

## Приоритизация

### Критично (сделать в первую очередь):
1. ✅ `DevelopmentSetupViewModel` - основной flow выбора параметров
2. ✅ `CalculatorViewModel` - расчеты времени проявки
3. ✅ Критические ошибки во всех try-catch блоках
4. ✅ Операции с базой данных (create/update/delete)

### Важно (сделать следующим):
1. ✅ `StagingViewModel` - управление стадиями
2. ✅ `CreateRecordViewModel` - создание записей
3. ✅ `SwiftDataService` - расширить существующее логирование
4. ✅ Навигация между экранами
5. ✅ Производительность долгих операций

### Полезно (опционально):
1. ⚪ `PresetService` - работа с пресетами
2. ⚪ `DevelopmentCalculator` - детали расчетов
3. ⚪ `ValidationManager` - валидация
4. ⚪ Детальные пользовательские действия

## Примеры имплементации

### Пример 1: Добавление логирования в DevelopmentSetupViewModel

```swift
import os.log

func selectFilm(_ film: SwiftDataFilm) {
    Logger.logUserAction("Film selected: \(film.name)", type: .info)

    selectedFilm = film
    iso = Int(film.defaultISO)

    if let currentDeveloper = selectedDeveloper {
        let availableDevelopers = dataService.getAvailableDevelopers(filmId: film.id)
        if !availableDevelopers.contains(where: { $0.id == currentDeveloper.id }) {
            Logger.logUserAction("Developer reset due to film change", type: .debug)
            selectedDeveloper = nil
            selectedDilution = ""
        }
    }

    calculateTimeAutomatically()
}

func calculateTimeAutomatically() {
    guard let film = selectedFilm,
          let developer = selectedDeveloper,
          !selectedDilution.isEmpty else {
        return
    }

    Logger.logCalculation("Auto-calculating time - film: \(film.name), developer: \(developer.name), dilution: \(selectedDilution)", type: .info)

    if let time = dataService.getDevelopmentTime(
        filmId: film.id,
        developerId: developer.id,
        dilution: selectedDilution,
        iso: iso
    ) {
        calculatedTime = time
        Logger.logCalculation("Time calculated: \(time)s", type: .info)
    } else {
        Logger.logCalculation("No development time found for combination", type: .error)
    }
}
```

### Пример 2: Добавление логирования в CalculatorViewModel

```swift
import os.log

func calculateTime() {
    Logger.logCalculation("Calculate time - minutes: \(minutes), seconds: \(seconds), coefficient: \(coefficient)", type: .info)

    guard isValidInput else {
        Logger.log(.error, "Invalid input for calculation")
        return
    }

    guard let min = Int(minutes), min >= 0,
          let sec = Int(seconds), sec >= 0, sec < 60,
          let coeff = Double(coefficient), coeff > 0 else {
        return
    }

    let temperatureMultiplier = swiftDataService.getTemperatureMultiplier(for: temperature)
    Logger.logCalculation("Temperature multiplier applied: \(temperatureMultiplier)", type: .debug)

    // ... остальной код ...

    pushResults = calculator.calculateResults(/*...*/)
    Logger.logCalculation("Results calculated - steps: \(pushResults.count)", type: .info)

    showResult = true
}

func startTimer(_ label: String, _ minutes: Int, _ seconds: Int) {
    Logger.logUserAction("Start timer - label: \(label), time: \(minutes):\(seconds)", type: .info)
    // ... код запуска таймера ...
}
```

### Пример 3: Логирование производительности

```swift
func syncDataFromGitHub() async throws {
    let startTime = Date()
    Logger.logSync("Starting data sync", type: .info)

    do {
        // ... синхронизация ...

        let duration = Date().timeIntervalSince(startTime)
        Logger.logSync("Sync completed in \(String(format: "%.2f", duration))s", type: .info)

        if duration > 5.0 {
            Logger.logSync("WARNING: Slow sync detected (\(String(format: "%.2f", duration))s)", type: .error)
        }
    } catch {
        let duration = Date().timeIntervalSince(startTime)
        Logger.logSync("Sync failed after \(String(format: "%.2f", duration))s: \(error)", type: .error)
        throw error
    }
}
```

## Итоговые рекомендации

1. **Начните с критичных ViewModels** - они влияют на пользовательский опыт
2. **Логируйте все ошибки** - это поможет быстро находить проблемы в production
3. **Используйте правильные категории** - это упростит фильтрацию в Console.app
4. **Логируйте ключевые действия пользователя** - поймете, как используется приложение
5. **Измеряйте производительность** - найдете узкие места
6. **Не переусердствуйте** - логируйте только полезную информацию

## Проверка эффективности логирования

После добавления логирования проверьте:
- ✅ Легко ли найти нужные логи через фильтры в Console.app?
- ✅ Содержат ли логи достаточно контекста для понимания проблемы?
- ✅ Не слишком ли много логов (шум)?
- ✅ Правильно ли используются уровни (debug, info, error)?
- ✅ Не влияет ли логирование на производительность?
