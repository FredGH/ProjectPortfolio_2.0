import numpy as np
import pandas as pd
import seaborn as sbn
from matplotlib import cm
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from geopy.geocoders import Nominatim
import folium

def get_cat_cols(data):
    return data.select_dtypes(exlcude=[np.number])


def get_num_cols(data):
    return data.select_dtypes(include=[np.number])


def get_col_names(data):
    return list(data.columns.values);


def get_num_data_and_schema(data):
    num_data = get_num_cols(data)
    num_data = num_data.dropna()
    num_col_headers = get_col_names(num_data)
    return num_col_headers, num_data


def statistics(data):
    for index, item in enumerate(data):
        print("Variable Name: %s" % item)
        print("Skewness: %f" % data[item].skew())
        print("Kurtosis: %f" % data[item].kurt())


def summary(data):
    print("First 10 records")
    print(data.head(10))
    print("\n Shape")
    print("rows X cols -> {} X {}".format(data.shape[0], len(data.columns)))
    print("\n  Data Types")
    print(data.dtypes)
    print("\n  Describe (excl missing data)")
    num_col_headers, num_data = get_num_data_and_schema(data)
    print(num_data.dropna().describe())
    print("\n  Extra statistics)")
    statistics(num_data)


def missing_data_values(data):
    missing = data.isnull().sum().sort_values(ascending=False)
    total = data.isnull().count().sort_values(ascending=False)
    percent = missing / total
    missing_data = pd.concat([missing, total, percent], axis=1, keys=['Missing', 'Total', 'Percent'])
    return missing_data.sort(['Percent'], ascending=[0])


# https://seaborn.pydata.org/tutorial/aesthetics.html
def set_default_plt_display(x=20, y=80, col_number=3):
    plt.figure(figsize=(x, y))
    gs = gridspec.GridSpec(x, col_number)
    sbn.set_style("darkgrid", {'grid.color': '.8', 'ytick.color': '.15'})
    return gs


def generate_histogram(grid_spec, index, data, column_name):
    x = pd.Series(data[column_name], name=column_name)
    ax = sbn.distplot(x, color="r")
    plt.subplot(grid_spec[index])


def generate_histograms(grid_spec, data):
    num_col_headers, num_data = get_num_data_and_schema(data)
    for index, item in enumerate(num_col_headers):
        generate_histogram(grid_spec, index, num_data, item)


def generate_box_plot(grid_spec, index, data, column_name):
    x = pd.Series(data[column_name], name=column_name)
    sbn.boxplot(x).set_title(column_name)
    plt.subplot(grid_spec[index])

def generate_box_plots(grid_spec, data):
    num_col_headers, num_data = get_num_data_and_schema(data)
    for index, item in enumerate(num_col_headers):
        generate_box_plot(grid_spec, index, num_data, item)


def generate_correlogram(data, size_inches=10):
    num_col_headers, num_data = get_num_data_and_schema(data)
    correlations = num_data.corr()
    # plot correlation matrix
    fig = plt.figure()
    fig.set_size_inches(size_inches,size_inches)
    ax = fig.add_subplot(111)
    cax = ax.matshow(correlations, vmin=-1, vmax=1,cmap=cm.coolwarm)
    fig.colorbar(cax)
    fig.patch.set_facecolor('white')
    ticks = np.arange(0, len(num_data.columns), 1)
    ax.set_xticks(ticks)
    ax.set_yticks(ticks)
    ax.set_xticklabels(num_col_headers, rotation=45)
    ax.set_yticklabels(num_col_headers)
    plt.show()


def generate_scatter_plots(data, size_inches=10):
    num_col_headers, num_data = get_num_data_and_schema(data)
    pd.plotting.scatter_matrix(num_data,  figsize=(size_inches, size_inches))
    plt.show()


def generate_histogram_cat(grid_spec, index, data, column_name):
    x = pd.Series(data[column_name], name=column_name)
    ax = sbn.distplot(x, color="r")
    plt.subplot(grid_spec[index])


def generate_histograms_cat(grid_spec, data):
    cat_data = data.select_dtypes(exclude=[np.number])
    cat_col_headers = cat_data.columns
    for index, item in enumerate(cat_col_headers):
        count = data.groupby(item)[item].count()
        cat_data_count = pd.concat([count], axis=1, keys=['Count'])
        generate_histogram_cat(grid_spec, index,cat_data_count, 'Count')


def describe_cat(data):
    cat_columns = data.select_dtypes(exclude=[np.number]).columns
    for index, item in enumerate(cat_columns):
        count = data.groupby(item)[item].count()
        res = pd.concat([count], axis=1, keys=['Count'])
        print("******************")
        print("*********")
        print("index: {}, name: {}".format(index, item))
        print("*********")
        print(res.sort_values(['Count'], ascending=[0]))
        print("*********")


def missing_data_values(data):
    missing = data.isnull().sum().sort_values(ascending=False)
    total = data.isnull().count().sort_values(ascending=False)
    percent = missing / total
    missing_data = pd.concat([missing, total, percent], axis=1, keys=['Missing', 'Total', 'Percent'])
    return missing_data.sort_values(['Percent'], ascending=[0])


def missing_data_plot(grid_spec, data, missing_data_threshold=0.6):
    missing_data = missing_data_values(data)
    missing_data_perc = missing_data['Percent']
    ax = missing_data_perc.plot(
        kind='bar',
        color=['#AA0000' if perc > missing_data_threshold else '#000088' for perc in missing_data_perc], )
    # ax = sbn.distplot(missing_data_perc, color="r")
    # plt.subplot(grid_spec[0])
    plt.show()


# adress: "175 5th Avenue NYC"
def get_location_full_details(address):
    geolocator = Nominatim()
    location = geolocator.geocode(address)
    return location.raw


def get_location_long_lat(address):
    geolocator = Nominatim()
    location = geolocator.geocode(address)
    return location.latitude, location.longitude


def create_map_data(addresses, cities, values):
    lats = list()
    longs = list()

    for i in range(0, len(addresses)):
        address = addresses[i]
        long, lat = get_location_long_lat(address)
        lats.append(lat)
        longs.append(long)

    data = pd.DataFrame({
        'lat': lats,
        'lon': longs,
        'name': cities,
        'value': values
    })
    return data


def get_map(data, tiles="Mapbox Bright", zoom_start=9):
    # Make an empty map
    avg_location = [data['lon'].mean(), data['lat'].mean()]
    m = folium.Map(location=avg_location, tiles=tiles, zoom_start=zoom_start)
    return m


def get_map_marker(data, tiles="Mapbox Bright", zoom_start=9):
    m = get_map(data, tiles, zoom_start)
    # I can add marker one by one on the map
    for i in range(0, len(data)):
        folium.Marker(location=[data.iloc[i]['lon'], data.iloc[i]['lat']], popup=data.iloc[i]['name']).add_to(m)
    return m


def get_map_circle(data, tiles="Mapbox Bright", zoom_start=9, factor = 1):
    m = get_map(data, tiles, zoom_start)
    # I can add marker one by one on the map
    for i in range(0, len(data)):
        folium.Circle(location= [data.iloc[i]['lon'], data.iloc[i]['lat']],
                      popup=data.iloc[i]['name'], radius=float(data.iloc[i]['value']) * factor,
                      color='crimson', fill=True, fill_color='crimson').add_to(m)
    return m
