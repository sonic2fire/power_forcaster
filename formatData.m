function [  ] = formatData()
%Formats a single table containing all the information for training the
%neural network
%IMPORTANT: INDEX NUMBERS ARE TAILORED FOR EACH SPECIFIC DATA SET TO
%IMPROVE PERFORMANCE. IF THE FILE NAME IS CHANGED, INDEXING WILL NEED TO BE
%CHANGED.
%Use the following function: datetime.setDefaultFormats('default','yyyy-MM-dd''T''HH:mm:ss')
tic
timeTAvgCellHistorical = table2cell(getHistoricalWeather('2017-01-01', '2018-02-22', 'TAVG'));
timePrcpCellHistorical = table2cell(getHistoricalWeather('2017-01-01', '2018-02-22', 'PRCP'));
timePrcpCellHistorical(:,1)=[];

[powerGen, time] = xlsread("Therm Gen MW", 'Sheet1', 'B1:C49468');
time(1,:)=[];
time=datetime(time(:,1));

trainingCell=table2cell(table(seconds(timeofday(time)),yyyymmdd(time),powerGen));
trainingCell{length(time),7} = [];


minimumJIndex=52;%first entry for the powerGen Dates in Tavg table
maximumJIndex= length(timeTAvgCellHistorical(:,1));

numberOfEntries=length(time);
for i=1:numberOfEntries
    
    if mod(i,1000)==0
        disp(i);
    end
    powerGenDate=yyyymmdd(time(i));
    %For every entry in the Therm Gen file, set the target date
    % to each entry one by one
    
    %The if statement checks to see if a day is a weekday (workday), or
    %weekend and then sets it to 1 if it is a workday.
   
    if weekday(datenum(num2str(powerGenDate),'yyyymmdd'))==1 || weekday(datenum(num2str(powerGenDate),'yyyymmdd'))==7
        trainingCell{i,6}=0;
    else
        trainingCell{i,6}=1;
    end
         
    
    
    for j=minimumJIndex:maximumJIndex
        compareDate =yyyymmdd(datetime(timeTAvgCellHistorical(j,1)));
        %This for loop goes through the historical data and 
        %compares the date at the most recent index and then one past that(since it only has  to the power gen date
        %then if it finds a match, updates the search index so that
        %the same date isn't looped over again.
        
        if compareDate==powerGenDate
            trainingCell{i,4}=timeTAvgCellHistorical{j,2};
            trainingCell{i,5}=timePrcpCellHistorical{j,1};
            minimumJIndex=j;
            break
        end
        
        
    end

%entry 146 is day 2 (day 1 starts at 2), so each previous 24 hr power is
%separated by 144 cells


end

for k=145:numberOfEntries
    trainingCell{k,7}=trainingCell{k-144,3};
end

%49468

%cutting off first 145 entries since we don't have the previous 24hr measure
%for it
trainingCell=trainingCell(145:numberOfEntries,:);
%%trainingCell{:,1}=trainingCell{:,1};


filename = 'trainingData';
col_header={'Time (sec)','Date (yyyymmdd)', 'Power Generated MW', 'Daily Avg Temp C', 'Precip cm', 'isWorkingDay', 'Previous day power'};
xlswrite (filename, trainingCell, 'Sheet1', 'A2');
xlswrite (filename,col_header, 'Sheet1', 'A1');
toc
end