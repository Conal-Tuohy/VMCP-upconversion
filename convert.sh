echo `date`: Conversion starting ...

XPROC="java -jar /usr/share/xmlcalabash-1.4.1-100/xmlcalabash-1.4.1-100.jar"

echo `date`: Retrieving ODT files from GitHub...
cd /home/RBGV_Admin/vmcp-odt/ && git pull

echo `date`: Removing  styles from  apparatus files
pandoc -f odt -t markdown ./apparatus/editors-citations.odt | pandoc -f markdown -t odt -o ./letters/apparatus/editors-citations.odt
pandoc -f odt -t markdown ./apparatus/honours-awards-memberships.odt | pandoc -f markdown -t odt -o ./letters/apparatus/honours-awards-memberships.odt
pandoc -f odt -t markdown ./apparatus/muellers-publications.odt | pandoc -f markdown -t odt -o ./letters/apparatus/muellers-publications.odt

echo `date`: Purging TEI
rm -r /usr/src/xtf/data/tei/letters/

echo `date`: Converting OpenDocument files to TEI format ...
time $XPROC /usr/src/VMCP-upconversion/xproc/upconvert.xpl input-directory=/home/RBGV_Admin/vmcp-odt output-directory=/usr/src/xtf/data/tei

echo `date`: Pushing changes in TEI to GitHub...
cd /usr/src/xtf/data/tei
mv letters/apparatus/* ./static/apparatus/
git add .
git commit -m "VMCP conversion pipeline run `date`"
git push origin main

echo `date`: Rebuilding XTF index ...
sudo -u tomcat /usr/src/xtf/bin/textIndexer -clean -index default

echo `date`: Restarting Tomcat webserver ...
sudo systemctl restart tomcat9
sudo systemctl status tomcat9 --no-pager

echo `date`: Conversion finished.