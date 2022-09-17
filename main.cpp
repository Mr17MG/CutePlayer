#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QLocale>
#include <QTranslator>

#include "player.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

//    QDir source{"/home/mohammad/Downloads"};
//    QStringList audioFormats{"*.mp3","*.wav","*.aiff","*.aac","*.ogg","*.wma","*.flac"};
//    QStringList const files = source.entryList(audioFormats, QDir::Files);

//    for(const QString &file: files)
//        qDebug() <<source.path()+QDir::separator()+file;

//    return 0;


    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "CutePlayer_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    qmlRegisterType<Player>("Player",1,0,"Player");

    QQmlApplicationEngine engine;
    const QUrl url("qrc:/main.qml");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
