echo `date`: Conversion starting ...

XPROC="java -cp /opt/VMCP-upconversion/calabash/lib/*:/opt/VMCP-upconversion/calabash/xmlcalabash-1.5.7-120.jar com.xmlcalabash.drivers.Main --safe-mode=false"
#java -jar /opt/VMCP-upconversion/calabash/xmlcalabash-1.5.7-120.jar"

#echo `date`: Retrieving ODT files from GitHub...
#mkdir -p /home
#cd /var/lib/vmcp-odt/ && git pull

#echo `date`: Removing  styles from  apparatus files
#pandoc -f odt -t markdown ./apparatus/editors-citations.odt | pandoc -f markdown -t odt -o ./letters/apparatus/editors-citations.odt
#pandoc -f odt -t markdown ./apparatus/honours-awards-memberships.odt | pandoc -f markdown -t odt -o ./letters/apparatus/honours-awards-memberships.odt
#pandoc -f odt -t markdown ./apparatus/muellers-publications.odt | pandoc -f markdown -t odt -o ./letters/apparatus/muellers-publications.odt#

echo `date`: Purging TEI
rm -r /var/lib/vmcp-tei/letters/

echo `date`: Converting OpenDocument files to TEI format ...
time $XPROC /opt/VMCP-upconversion/xproc/upconvert.xpl input-directory=/var/lib/vmcp-odt output-directory=/var/lib/vmcp-tei

echo `date`: Pushing changes in TEI to GitHub...
cd /var/lib/vmcp-tei
mv letters/apparatus/* ./static/apparatus/
#git add .
#git commit -m "VMCP conversion pipeline run `date`"
#git push origin main

echo `date`: Conversion finished.