docker rm -f elementdata

settingsFile=$(pwd)/elementdata.settings.ini

docker run -d --name elementdata \
   -v $settingsFile:/root/.config/ElementData/Settings.ini \
   elementdata/elementdata_cli:arm64
