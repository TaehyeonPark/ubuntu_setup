export HOMEBREW_PREFIX="/home/work/.linuxbrew";
export HOMEBREW_CELLAR="/home/work/.linuxbrew/Cellar";
export HOMEBREW_REPOSITORY="/home/work/.linuxbrew";
export PATH="/home/work/.linuxbrew/bin:/home/work/.linuxbrew/sbin${PATH+:$PATH}";
export MANPATH="/home/work/.linuxbrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/home/work/.linuxbrew/share/info:${INFOPATH:-}";

cd ~/remote_ai/
cp ./id_rsa ~/.ssh/
chmod 600 ~/.ssh/id_rsa
screen -dmS 7860 ssh -N -R 7860:127.0.0.1:7860 nai.taehyeon.me -l tunnel
screen -S 7860 -X stuff "yes^M"

cd stable-diffusion-webui
python -m pip install -U pip wheel setuptools
python -m pip install -U opencv_python numexpr
python launch.py --api
