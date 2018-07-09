function [timeDataTable] = getHistoricalWeather(startDatei,endDatei, dataType)
%getHistoricalWeather This function takes in a start date, end date, and data type,
%then finds the specified data for each day in the data range. Uses the
%NOAA api v2. Dates are formatted as 'YYYY-MM-DD'. dataType can be found on
%CDO databse, examples are 'TMAX', 'TAVG', 'TMIN', and 'PRCP'.



    startDate = startDatei;
    year = str2num(startDate(1:4));
    nextYear = year + 1;
    pYear = 0;
    data = [];
    time = [];
%Creates the start date and sets the next year to be one year ahead
%which allows us to get around the one year limit per GET request.

    while (nextYear ~= pYear)
        pYear = nextYear;
        %while loop runs as long as the next year is not equal to the
        %current year, it will loop until we have covered every single
        %year.
        
        if (nextYear > str2num(endDatei(1:4)))
            endDate = endDatei;
            %this sets the end date as the final end date
        else
            endDate = strcat(num2str(nextYear),startDate(5:length(startDate)));
            % this sets the end date with a modified year with the month
            % and day of the original end date.
        end

        token = "URLjugNcOKuFrDbDXtfXwJzXOUabNpdd";
        options = weboptions('Timeout', 100, 'HeaderFields',["token",token]);
        %This is where the timeout and token fields are filled out to make
        %a RESTful api request.

        %locationID = 'CITY:US490006';
        stationID = 'GHCND:USW00024127';
        dataSetID= 'GHCND';
        dataTypeID = dataType;
        limit = '1000';
        unit = 'metric';
        %The above lines are specific fields that can limit our search
        %using the API
        %API Documentation: https://www.ncdc.noaa.gov/cdo-web/webservices/v2#data

        api_data = 'https://www.ncdc.noaa.gov/cdo-web/api/v2/data';
        url_data = [api_data '?datasetid=' dataSetID '&startdate=' startDate ...
        '&enddate=' endDate '&datatypeid=' dataTypeID '&limit=' limit '&unit=' unit '&stationid=' stationID];

        weatherData=webread(url_data,options);
        % This queries the final url assembled above for the information
        % requested.
        
        datai=struct2table(weatherData.results);
        datai= table2array(datai(:,5));
        
        data = [data; datai];

        timei=struct2table(weatherData.results);
        timei= timei(:,1);
        time = [time; timei];
        %all the lines above retrieve different parts of the weatheData
        %Structure that is returned.

        startDate = endDate;
        year = str2num(startDate(1:4));
        nextYear = year + 1;
    end
    
    
    if (strcmp(dataTypeID,'TAVG'))
        data=data./10;
        timeDataTable = [time,array2table(data)];
        timeDataTable.Properties.VariableNames = {'dateAndTime' 'AvgTemperatureCelsius'};
        
    elseif (strcmp(dataTypeID,'TMAX'))
        data=data./10;
        timeDataTable = [time,array2table(data)];
        timeDataTable.Properties.VariableNames = {'dateAndTime' 'MaxtemperatureCelsius'};
        
    elseif (strcmp(dataTypeID,'TMIN'))
        data=data./10;
        timeDataTable = [time,array2table(data)];
        timeDataTable.Properties.VariableNames = {'dateAndTime' 'MintemperatureCelsius'};
        
    elseif (strcmp(dataTypeID,'PRCP'))
        data=data./100;
        timeDataTable = [time,array2table(data)];
        timeDataTable.Properties.VariableNames = {'dateAndTime' 'AvgPrecipitationCentimeters'};
        
    end
    %The final if simply formats the time and data column labels depending
    %on what data type was requested.
        
end

