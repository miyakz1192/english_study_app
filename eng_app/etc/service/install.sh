service_file=eng_app.service

echo "installing eng_app boot file to system"

echo "copying service file ${service_file} to /etc/systemd/system"
sudo cp ${service_file} /etc/systemd/system
sudo chown root:root /etc/systemd/system/${service_file}
sudo chmod 644 /etc/systemd/system/${service_file}

echo "daemon-reload and enabling ${service_file}"
sudo systemctl daemon-reload
sudo systemctl enable ${service_file}
sudo systemctl status ${service_file}
