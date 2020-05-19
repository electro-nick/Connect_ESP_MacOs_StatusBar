# Connect_ESP_MacOs_StatusBar

![](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/Images/app.png)

Ссылки: 
* **[YouTube Канал](https://www.youtube.com/channel/UCM-XygZwEYf7gJTsNsHrFew)**
* **[Группа ВК](https://vk.com/public_electro_nick)**
* **[Сайт с проектами и детальным описанием](http://electro-nick.ru)**

### Активация Статус бар приложения:
В файле **info.plist** добавить параметр `Application is agent (UIElement)` и придать ему значение: `YES`

**Примечание:**
* Если не хотим что бы вместе с приложением в статус баре запускалась декстопная версия, то убираем инициализацию `ViewController` в `Main.storyboard`

![](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/Images/img2.png)

### Скрыть приложение при клике на область экрана

Для того, что бы при нажатии на любую часть экрана у нас скрывалось приложение в статус бар нам необходимо:

1. Объявить переменную `eventMonitor` в классе [AppDelegate](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/StatusBar/AppDelegate.swift)

`var eventMonitor: EventMonitor?`

2. В функции `func applicationDidFinishLaunching(_ aNotification: Notification)` инициализировать класс [EventMonitor](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/StatusBar/EventMonitor.swift)

`eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
          if let strongSelf = self, strongSelf.popover.isShown {
            self!.popover.close()
          }
        }`

3. Далее в классе `AppDelegate` имплементировать класс `NSPopoverDelegate` и создать 2 функции:

* `func popoverDidShow(_ notification: Notification) { eventMonitor?.start() }`
* `func popoverDidClose(_ notification: Notification) { eventMonitor?.stop() }`

В них просто останавливаем слушатель кликов когда приложение скрыто в статус бар, и запускаем когда открыто.

### Настройка общения с ESP

Разрешаем соединение с сервером**

![](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/Images/img1.png)

Объявляем и инициализируем класс **[UDP](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/StatusBar/UDP.swift)** для общения с ESP.

Объявляем переменную `udp` в классе `StatusBarViewController`:

`var udp: UDP? = nil`

Инициализируем класс `UDP`, прописываем айпи и порт, и передаем слушатель как параметр функции:

_Айпи мы прописывали в arduino IDE. Он статичен._

### Инициализация:
* `udp = UDP(ip: "192.168.0.187", port: 4210, onSuccess: { stateServerHelper in ... })`

* `onSuccess: { stateServerHelper in ... }` - это слушатель. Тут ловим ответ от ESP. [Смотреть пример](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/StatusBar/StatusBarViewController.swift). 30 строка!

Внутри есть метод `DispatchQueue.main.async { }`. Он нужен для того, что бы обновлять визуал внутри другого потока.

### Методы:
1. `func send( key: String, value: String, onError: @escaping ( String ) -> Void)`

`onError: @escaping ( String ) -> Void)` - Мы просто отправляем функцию как параметр. Она вызывается, если возникает ошибка при отправке. Возвращает тип String.

### Описание:
1. Отправка строки на ESP

### Примеры:

1. `udp?.send(key: "power", value: "1", onError: { err in print(err) })` - Включить лампу.
2. `udp?.send(key: "brightness", value: "60", onError: { err in print(err) })` - Установить яркость лампы. от 0 до 255.
3. `udp?.send(key: "mode", value: "2", onError: { err in print(err) })` - Установить 2 режим работы лампы.
4. `udp?.send(key: "color", value: "255 0 0", onError: { err in print(err) })` - Установить цвет лампы в формате RGB.
5. `udp?.send(key: "getPowerState", value: "", onError: { err in print(err) })` - Получить ответ из ESP. Тут уже сложнее. Более подробно описано ниже.

Прописываем таймер, который будет вызываться каждые 2 секунды:

* `Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: {_ in ... })`

Далее внутри вызываем функцию, которая будет сообщать ESP что мы хотим получить данные от нее:

* `self.udp?.send(key: "getPowerState", value: "", onError: { err in print(err) })`

Далее ловим ответ в конструкторе и меняем состояние вьюхи. [Смотреть пример](https://github.com/electro-nick/Connect_ESP_MacOs_StatusBar/blob/master/StatusBar/StatusBarViewController.swift). 30 строка!
