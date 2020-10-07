# title: Read data on Vinex classification
# author: Trond
# date: 7.10.2020

# house keeping
import geopandas as gpd
import pandas as pd
import numpy as np
import os
import cbsodata

'''
Read in data
'''


# read in data on typolog
excel_file_name = 'vinex_2013_indeling/CBS_Buurt2013_Vinex_uitleg_type.xlsx'
vinex_types = pd.read_excel(input_path + excel_file_name)

vinex_type_desc = pd.read_excel(input_path + excel_file_name, sheet_name = 1)

# buurt en wijk kaarten
bw_zip_url = 'http://download.cbs.nl/regionale-kaarten/shape-2013-versie-3-0.zip'
bw_file_name = input_path + 'buurt_wijk_kaart_2013/buurt_wijk_kaart_2013.zip'

if not os.path.isfile(bw_file_name):
    print('Downloading buurt en wijk kaarten')
    r = requests.get(bw_zip_url)
    with open(bw_file_name, 'wb') as f:
        f.write(r.content)

bw_shp = gpd.read_file('zip:///' + bw_file_name + '!uitvoer_shape/buurt_2013.shp')

# for future reference: read straight from url
# http://andrewgaidus.com/Reading_Zipped_Shapefiles/

# data on regional division 2013
cbs_tables = cbsodata.get_table_list()

def find_identifier(cbs_tables, search_list):
    for tbl in cbs_tables:
        if all(x in tbl['Title'] for x in search_list):
            identifier = tbl['Identifier']
    return identifier

gebieden_2013_id = find_identifier(cbs_tables, ['Gebieden', '2013'])
gebieden_2013 = pd.DataFrame(cbsodata.get_data(gebieden_2013_id))


'''
Data wrangling
'''

# stadsgewesten columns
sg_names = ['Code_1', 'Naam_5', 'Code_6', 'Naam_45', 'Code_46']

# clean up and create legible names
stadsgewesten = gebieden_2013[sg_names]. \
                apply( lambda x: x.str.rstrip() ). \
                rename(columns = {
                    'Naam_5' : 'Corop_naam',
                    'Code_6' : 'Corop_code',
                    'Naam_45' : 'Stadsgewest_naam',
                    'Code_46' : 'Stadsgewest_code'})

# add to buurt and wijk kaarten
bw_shp = bw_shp.join(stadsgewesten.set_index('Code_1'),
                     on = 'GM_CODE')

# create three Vinex categories
vinex_naam_dict = {'Stadsdeel' : 0,
                   'Zelfstandige wijk': 1,
                   'Wijkinvulling' : 2,
                   'Dorpsuitbreiding' : 2}

vinex_type_dict = {'Stadsdeel' : 'Stadsdeel',
                   'Zelfstandige wijk' : 'Zelfstandige wijk',
                   'Wijkinvulling' : 'Wijkinvulling/Dorpsuitbreiding',
                   'Dorpsuitbreiding' : 'Wijkinvulling/Dorpsuitbreiding'}

# add these to the description
vinex_type_desc['Vinex_cat'] = vinex_type_desc['Type_naam']. \
                                    map(vinex_naam_dict)
vinex_type_desc['Vinex_type_upd'] = vinex_type_desc['Type_naam']. \
                                    map(vinex_type_dict)

# add the updated description to the buurt typology
vinex_type_names = ['Vinex_type', 'Vinex_type_upd', 'Vinex_cat']
vinex_types = vinex_types.join(vinex_type_desc[vinex_type_names]. \
                               set_index('Vinex_type'),
                               on = 'Vinex_type')

# merge buurt en wijk kaarten with vinex typology
vinex_type_names.insert(0, 'Vinex_naam')
vinex_type_names.insert(0, 'BU2013CODE')

vinex_merged = bw_shp[bw_shp['WATER'] == 'NEE']. \
               join(vinex_types[vinex_type_names]. \
                    set_index('BU2013CODE'),
                    on ='BU_CODE',
                    how = 'right')

# reproject
vinex_merged = vinex_merged.to_crs("EPSG:4326")

# check how the geojson file looks like
#vinex_merged.iloc[:1, ].to_json()

# add vinex indicator to buurt and wijk kaarten and reproject
bw_shp = bw_shp.join(vinex_types[vinex_type_names].set_index('BU2013CODE'),
                     on = 'BU_CODE'). \
                     to_crs("EPSG:4326")

# add indicatior dummy for Vinex
bw_shp['Vinex'] = np.where(bw_shp['Vinex_type'].isna(), 0, 1)

# end of code
