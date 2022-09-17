#include "player.h"

Player::Player(QObject *parent)
    : QObject{parent}
{

    m_player = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);
    m_player->setAudioOutput(m_audioOutput);

    connect(m_audioOutput, &QAudioOutput::volumeChanged, this, &Player::volumeChanged);
    connect(m_audioOutput, &QAudioOutput::mutedChanged, this, &Player::mutedChanged);

    connect(m_player, QOverload<>::of(&QMediaPlayer::metaDataChanged), this, &Player::metaDataChanged);

    connect(m_player, &QMediaPlayer::sourceChanged, this, &Player::sourceChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &Player::durationChanged);
    connect(m_player, &QMediaPlayer::positionChanged, this, &Player::positionChanged);
    connect(m_player, &QMediaPlayer::playbackStateChanged, this, &Player::playbackStateChanged);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &Player::mediaStatusChanged);
    connect(m_player, &QMediaPlayer::bufferProgressChanged, this, &Player::bufferProgressChanged);
    connect(m_player, &QMediaPlayer::errorChanged, this, &Player::displayErrorMessage);
    connect(m_player, &QMediaPlayer::seekableChanged, this, &Player::seekableChanged);

    m_shuffle = ShuffleMode::ShuffleOff;
    m_loop = LoopMode::LoopAll;
}

void Player::setSource(const QString &source)
{
    if( this->m_player->playbackState() == QMediaPlayer::PlayingState )
        this->m_player->stop();

    this->m_player->setSource(QUrl::fromLocalFile(source));
}

void Player::setVolume(const float &newVolume)
{
    this->m_audioOutput->setVolume(newVolume);
}

void Player::setMuted(const bool &muted)
{
    this->m_audioOutput->setMuted(muted);
}

void Player::setPosition(const qint64 &position)
{
    this->m_player->setPosition(position);
}

void Player::addMediaToPlayList(const QString &source)
{
    this->m_playlist.append(source);
}

void Player::addNMediaToPlayList(const QStringList &sourceList)
{
    this->m_playlist.append(sourceList);
}

void Player::resetPlayList()
{
    this->m_playlist.clear();
    this->m_currentIndexInPlaylist = -1;
}

void Player::play()
{
    if(this->m_player->source().isEmpty()) {
        if ( this->m_playlist.count() > 0 ){
            this->setSource(this->m_playlist[this->m_currentIndexInPlaylist]);
        }
    }

    this->m_player->play();
}

void Player::stop()
{
    this->m_player->stop();
}

void Player::pause()
{
    this->m_player->pause();
}

void Player::setLoop(const LoopMode &loop)
{
    this->m_loop = loop;
    emit loopChanged(this->m_loop);
}

void Player::setShuffle(const ShuffleMode &mode)
{
    this->m_shuffle = mode;
    emit shuffleChanged(this->m_shuffle);
}

void Player::next()
{
    if (this->m_shuffle == Player::ShuffleOn)
    {
        this->m_currentIndexInPlaylist =  QRandomGenerator::global()->bounded(0,this->m_playlist.count());;
    }
    else {
        this->m_currentIndexInPlaylist = ( this->m_currentIndexInPlaylist+1 ) % this->m_playlist.count();
    }

    this->setSource( this->m_playlist[m_currentIndexInPlaylist] );

    this->play();
}

void Player::previous()
{

    if( this->m_player->position() < 5000 ) {
        if (this->m_shuffle == Player::ShuffleOn)
        {
            this->m_currentIndexInPlaylist =  QRandomGenerator::global()->bounded(0,this->m_playlist.count());;
        }
        else {
            this->m_currentIndexInPlaylist = (this->m_currentIndexInPlaylist-1) % this->m_playlist.count();
        }
    }

    this->m_currentIndexInPlaylist = this->m_currentIndexInPlaylist < 0 ? this->m_playlist.count() -1
                                                                        : this->m_currentIndexInPlaylist;

    this->setSource( this->m_playlist[m_currentIndexInPlaylist] );

    this->play();
}

qint64 Player::position()
{
    return m_player->position();
}

float Player::volume()
{
    return this->m_audioOutput->volume();
}

bool Player::muted()
{
    return this->m_audioOutput->isMuted();
}

QMediaPlayer::PlaybackState Player::playbackState()
{
    return this->m_player->playbackState();
}

bool Player::isSeekable()
{
    return this->m_player->isSeekable();
}

Player::ShuffleMode Player::shuffle() const
{
    return this->m_shuffle;
}

Player::LoopMode Player::loop() const
{
    return this->m_loop;
}

int Player::currentIndexInPlaylist() const
{
    return this->m_currentIndexInPlaylist;
}

void Player::setCurrentIndexInPlaylist(const int &newCurrentIndexInPlaylist)
{
    this->m_currentIndexInPlaylist = newCurrentIndexInPlaylist;
}

void Player::metaDataChanged()
{
    auto metaData = m_player->metaData();
    QString titleName = metaData.value(QMediaMetaData::Title).toString();
    emit trackTitleChanged(titleName);
    emit artistChanged(metaData.value(QMediaMetaData::AlbumArtist).toString());


    if(metaData.value(QMediaMetaData::ThumbnailImage).isNull() == false)
    {
        this->saveThumbnailAsFile(metaData.value(QMediaMetaData::CoverArtImage).value<QImage>(),titleName);
    }
    else if(metaData.value(QMediaMetaData::CoverArtImage).isNull() == false)
    {
        this->saveThumbnailAsFile(metaData.value(QMediaMetaData::CoverArtImage).value<QImage>(),titleName);
    }
    else {
        emit thumbnailChanged("");
    }
}

void Player::displayErrorMessage()
{
    if (m_player->error() == QMediaPlayer::NoError)
        return;
    qDebug()<< this->m_player->errorString();
}

void Player::bufferProgressChanged(const float &progress)
{
    qDebug() << "Buffering process: "<< progress;
}

void Player::saveThumbnailAsFile(const QImage &thumbnail, const QString &fileName)
{

    QDir dir = dir.tempPath() + QDir::separator() + "CutePlayer";

    if (dir.exists() == false)
    {
        dir.mkpath(dir.path());
    }

    QFile tempFile{ dir.path() + QDir::separator() + fileName + ".jpg" };

    if( tempFile.open(QFile::WriteOnly) )
    {
        thumbnail.save(tempFile.fileName(),"jpg"); // JPG is smaller in size than PNG
        emit thumbnailChanged(tempFile.fileName());
    }
    else {
        emit thumbnailChanged("");
    }
}

void Player::mediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    if(status == QMediaPlayer::EndOfMedia)
    {
        if(this->m_loop == Player::LoopOff && this->m_shuffle == Player::ShuffleOff)
        {
            if (this->m_currentIndexInPlaylist == this->m_playlist.count()-1)
            {
                this->stop();
            }
            else {
                this->next();
            }
        }

        else if(this->m_loop == Player::LoopOnce)
        {
            this->stop();
            this->play();
        }

        else {
            this->next();
        }
    }

    //    qDebug() << "MediaStatus:" << status;
}
