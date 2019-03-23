	##########################Data for Pie Chart#############################				 
  
    te = pd.DataFrame({'label' : []})
    te_legend = pd.DataFrame({'label' : []})
	
    dg=df[['RACE', 'SEX']]
    df_pie = dg.groupby(['RACE']).count()
    aa=pd.DataFrame(df_pie)
    n_pie=aa.count()
    te['label'] = aa.index
    te['value'] = aa['SEX'].values.tolist()
    te['color'] = color_pie[:4]
    te['highlight'] = color_pie[:4] 
	
    te_legend['label'] = te['label']
    te_legend['color'] = color_pie_txt[:4]
	
    json_pie=mark_safe(te.to_json(orient = "records"))

    for x in range(4):
        color_pie_txt[x] = mark_safe(color_pie_txt[x] + te['label'][x]+ "</li>")
    #########################################################################