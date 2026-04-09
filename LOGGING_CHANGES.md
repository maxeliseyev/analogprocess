# Обновления системы логирования

## Обзор изменений

Система логирования была полностью обновлена для поддержки получения логов с реальных устройств и TestFlight сборок.

## Что изменилось

### 1. Обновлен Logger.swift

**Добавлены новые возможности:**
- Поддержка OSLog для профессионального логирования
- Логи теперь доступны через Console.app на Mac
- Работает на реальных устройствах и в TestFlight

**Новые категории логирования:**
- `Timer` - операции таймера
- `Agitation` - система агитации
- `Persistence` - работа с базой данных
- `Sync` - синхронизация данных
- `Navigation` - навигация по приложению
- `UI` - пользовательский интерфейс
- `General` - общие логи

**Специализированные методы:**
```swift
Logger.logTimer("message", type: .info)
Logger.logAgitation("message", type: .default)
Logger.logPersistence("message", type: .error)
Logger.logSync("message", type: .info)
Logger.logNavigation("message", type: .debug)
Logger.logUI("message", type: .debug)
Logger.log(.error, "general message")
```

### 2. Обновлены файлы с логированием

**Core:**
- `SwiftDataPersistence.swift` - детальное логирование инициализации и восстановления БД
- `AutoSyncService.swift` - логи синхронизации и состояния сети
- `GitHubAgitationService.swift` - логи обновления режимов агитации
- `AgitationRuleEngine.swift` - логи инициализации пресетов
- `CoachMarksService.swift` - логи отображения подсказок
- `MainTabView.swift` - логи навигации

**Features:**
- `UnifiedTimerViewModel.swift` - подробное логирование работы таймера:
  - Инициализация
  - Запуск/пауза/сброс
  - Тики таймера (первые 5 и каждый 10-й)
  - Время создания Timer объекта
  - Задержки выполнения
  - Настройка и переключение фаз агитации

### 3. Преимущества новой системы

**Для разработки:**
- В DEBUG режиме: видны в Xcode консоли через `print()`
- Все логи также записываются через OSLog

**Для production и TestFlight:**
- Логи доступны через Console.app на Mac
- Можно фильтровать по категориям
- Можно экспортировать для анализа
- Автоматическое управление производительностью

**Производительность:**
- OSLog оптимизирован для производительности
- Логи не влияют на скорость приложения
- Автоматическое управление хранением

## Как использовать

### Во время разработки

Просто читайте логи в Xcode Console как обычно - они будут выводиться через `print()` в DEBUG режиме.

### На реальном устройстве или TestFlight

1. Подключите устройство к Mac
2. Откройте Console.app
3. Выберите устройство
4. Фильтруйте по категориям:
   - `category:Timer` - только таймер
   - `category:Sync` - только синхронизация
   - `category:Persistence` - только БД
   - И т.д.

Подробная инструкция в файле `LOGGING_GUIDE.md`.

## Примеры логов

### Запуск таймера
```
[Timer] [2025-12-07 23:45:12] startPauseTimer called - isRunning: false
[Timer] [2025-12-07 23:45:12] Starting timer
[Timer] [2025-12-07 23:45:12] startTimer BEGIN
[Timer] [2025-12-07 23:45:12] State before start - remainingSeconds: 300, totalSeconds: 300
[Timer] [2025-12-07 23:45:12] Tick counter reset to 0
[Timer] [2025-12-07 23:45:12] isRunning set to true
[Timer] [2025-12-07 23:45:12] Timer object created (creation took 0.002s)
[Timer] [2025-12-07 23:45:12] Timer scheduled on RunLoop - isValid: true
[Agitation] [2025-12-07 23:45:12] setupAgitation BEGIN - mode: Developer
[Timer] [2025-12-07 23:45:12] startTimer END (total duration: 0.015s)
[Timer] [2025-12-07 23:45:13] Timer fired - isValid: true
[Timer] [2025-12-07 23:45:13] Tick #1 - remainingSeconds: 300
```

### Инициализация БД
```
[Persistence] [2025-12-07 20:30:05] Starting SwiftData initialization (inMemory: false)
[Persistence] [2025-12-07 20:30:05] Using schema v1.1 with entities: [Film, Developer, ...]
[Persistence] [2025-12-07 20:30:05] Using on-disk storage
```

### Синхронизация
```
[Sync] [2025-12-07 20:30:15] Internet connection is available
[Sync] [2025-12-07 20:30:20] Data synchronized successfully
[Sync] [2025-12-07 20:30:20] Updated 8 agitation modes from GitHub
```

## Отладка проблем

### Проблема с запуском таймера

**Что искать в логах:**
1. Задержка между `startPauseTimer called` и `Tick #1`
2. Время создания Timer: `Timer object created (creation took X.XXXs)`
   - Если > 0.1s - проблема
3. Предупреждения: `WARNING: updateTimer took X.XXXs`
4. Проблемы с агитацией в логах `setupAgitation`

### Проблема с синхронизацией

**Фильтр в Console.app:**
```
category:Sync type:error
```

### Проблема с БД

**Фильтр в Console.app:**
```
category:Persistence
```

## Дальнейшие улучшения

Возможные будущие улучшения:
- Добавить метрики производительности
- Добавить remote logging для сбора статистики
- Добавить уровни детализации логирования
- Добавить автоматическую отправку crash reports

## Документация

- `LOGGING_GUIDE.md` - Полная инструкция по получению логов
- `Logger.swift` - Реализация системы логирования
