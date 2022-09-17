#ifndef PLAYER_H
#define PLAYER_H

#include <QObject>
#include <QMediaPlayer>
#include <QMediaMetaData>
#include <QAudioOutput>
#include <QImage>
#include <QDir>
#include <QFile>

#include <QRandomGenerator>
#include <QFileSystemWatcher>


class Player : public QObject
{
    Q_OBJECT


public:

    enum LoopMode {
        LoopOnce,
        LoopAll,
        LoopOff
    };
    Q_ENUM(LoopMode)

    enum ShuffleMode {
        ShuffleOn,
        ShuffleOff
    };
    Q_ENUM(ShuffleMode)

    explicit Player(QObject *parent = nullptr);
    ~Player() = default;

    Q_INVOKABLE void setSource(const QString &source);
    Q_INVOKABLE void setVolume(const float &newVolume);
    Q_INVOKABLE void setMuted(const bool &muted);
    Q_INVOKABLE void setPosition(const qint64 &position);

    Q_INVOKABLE void setLoop(const Player::LoopMode &loop);
    Q_INVOKABLE void setShuffle(const Player::ShuffleMode &mode);

    Q_INVOKABLE void addMediaToPlayList(const QString &source);
    Q_INVOKABLE void addNMediaToPlayList(const QStringList &sourceList);

    Q_INVOKABLE void resetPlayList();

    Q_INVOKABLE void play();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void pause();


    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();

    Q_INVOKABLE qint64 position();
    Q_INVOKABLE float volume();
    Q_INVOKABLE bool muted();
    Q_INVOKABLE QMediaPlayer::PlaybackState playbackState();
    Q_INVOKABLE bool isSeekable();

    Q_INVOKABLE Player::ShuffleMode shuffle() const;

    Q_INVOKABLE Player::LoopMode loop() const;

    Q_INVOKABLE int currentIndexInPlaylist() const;
    Q_INVOKABLE void setCurrentIndexInPlaylist(const int &newCurrentIndexInPlaylist);

private:
    QMediaPlayer *m_player = nullptr;
    QAudioOutput *m_audioOutput = nullptr;

//    QFileSystemWatcher *m_fileSystemWatcher= nullptr;

    QStringList m_playlist{};

    ShuffleMode m_shuffle;
    LoopMode m_loop;

    int m_currentIndexInPlaylist{};


signals:
    void volumeChanged(float volume);
    void mutedChanged(bool muted);

    void sourceChanged(const QUrl &media);

    void durationChanged(qint64 duration);
    void positionChanged(qint64 position);

    void playbackStateChanged(QMediaPlayer::PlaybackState newState);

    void trackTitleChanged(QString trackTitle);
    void artistChanged(QString artist);

    void seekableChanged(bool seekable);

    void thumbnailChanged(QString source);

    void shuffleChanged(const Player::ShuffleMode &newShuffle);
    void loopChanged(const Player::LoopMode &newLoop);

private slots:
    void metaDataChanged();
    void displayErrorMessage();
    void bufferProgressChanged(const float &progress);
    void saveThumbnailAsFile(const QImage &thumbnail,const QString &fileName);
    void mediaStatusChanged(QMediaPlayer::MediaStatus status);
//    void directoryChanged(const QString &path);
};

#endif // PLAYER_H
