<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/layouts_admin/init.jsp" %>

<%
Layout selLayout = null;

boolean privateLayout = false;
long parentPlid = LayoutConstants.DEFAULT_PLID;
long parentLayoutId = LayoutConstants.DEFAULT_PARENT_LAYOUT_ID;

if (layout.isTypeControlPanel()) {
	long selPlid = ParamUtil.getLong(liferayPortletRequest, "selPlid");

	if (selPlid != 0) {
		selLayout = LayoutLocalServiceUtil.getLayout(selPlid);

		privateLayout = selLayout.isPrivateLayout();
		parentPlid = selLayout.getPlid();
		parentLayoutId = selLayout.getLayoutId();
	}
	else {
		String tabs1 = ParamUtil.getString(request, "tabs1", "public-pages");

		privateLayout = tabs1.equals("my-dashboard") || tabs1.equals("private-pages");
	}
}
else {
	selLayout = layout;

	privateLayout = selLayout.isPrivateLayout();
	parentPlid = layout.getParentPlid();
	parentLayoutId = layout.getParentLayoutId();
}

Group liveGroup = GroupLocalServiceUtil.getGroup(scopeGroupId);

if (liveGroup.isStagingGroup()) {
	liveGroup = liveGroup.getLiveGroup();
}

String rootNodeName = liveGroup.getLayoutRootNodeName(privateLayout, locale);
%>

<aui:model-context model="<%= Layout.class %>" />

<portlet:actionURL var="editLayoutActionURL" windowState="<%= LiferayWindowState.EXCLUSIVE.toString() %>">
	<portlet:param name="struts_action" value="/layouts_admin/edit_layouts" />
</portlet:actionURL>

<portlet:renderURL var="editLayoutRenderURL" windowState="<%= LiferayWindowState.EXCLUSIVE.toString() %>">
	<portlet:param name="struts_action" value="/layouts_admin/edit_layouts" />
</portlet:renderURL>

<aui:form action="<%= editLayoutActionURL %>" enctype="multipart/form-data" method="post" name="addPageFm" onSubmit="event.preventDefault()">
	<aui:input id="addLayoutCMD" name="<%= Constants.CMD %>" type="hidden" value="<%= Constants.ADD %>" />
	<aui:input id="addLayoutRedirect" name="redirect" type="hidden" value="<%= layout.isTypeControlPanel() ? currentURL : editLayoutRenderURL.toString() %>" />
	<aui:input id="addLayoutGroupId" name="groupId" type="hidden" value="<%= scopeGroupId %>" />
	<aui:input id="addLayoutPrivateLayout" name="privateLayout" type="hidden" value="<%= privateLayout %>" />
	<aui:input id="addLayoutParentPlid" name="parentPlid" type="hidden" value="<%= parentPlid %>" />
	<aui:input id="addLayoutParentLayoutId" name="parentLayoutId" type="hidden" value="<%= parentLayoutId %>" />
	<aui:input id="addLayoutType" name="type" type="hidden" value="portlet" />
	<aui:input id="addLayoutPrototypeId" name="layoutPrototypeId" type="hidden" value="" />
	<aui:input id="addLayoutExplicitCreation" name="explicitCreation" type="hidden" value="<%= true %>" />

	<aui:fieldset>
		<div class="row-fluid">
			<div class="span12">
				<aui:input id="addLayoutName" name="name" />

				<aui:input id="addLayoutHiddenCheckbox" label="hide-from-navigation-menu" name="hidden" />

				<aui:fieldset cssClass="template-selector" label="templates">
					<div class="btn-toolbar search-panel">
						<aui:input cssClass="search-query span12" id="addLayoutSearchTemplates" label="" name="searchTemplates" placeholder="search" type="text"  />
					</div>

					<aui:nav cssClass="nav-list" id="templateList">
						<c:if test='<%= ArrayUtil.contains(PropsValues.LAYOUT_TYPES, "portlet") %>'>
							<aui:nav-item cssClass="lfr-page-template" data-search="blank">
								<div class="active lfr-page-template-title toggler-header toggler-header-expanded" data-type="portlet">
									<aui:input checked="<%= true %>" id="addLayoutSelectedPageTemplateBlank" label="empty-layout" name="selectedPageTemplate" type="radio" />

									<div class="lfr-page-template-description">
										<small><%= LanguageUtil.get(pageContext, "empty-layout-description" ) %></small>
									</div>
								</div>

								<div class="lfr-page-template-options toggler-content toggler-content-expanded">

									<%
									String layoutTemplateId = PropsValues.DEFAULT_LAYOUT_TEMPLATE_ID;
									String layoutTemplateIdPrefix = "addLayout";

									Theme selTheme = layout.getTheme();

									List<LayoutTemplate> layoutTemplates = LayoutTemplateLocalServiceUtil.getLayoutTemplates(selTheme.getThemeId());
									%>

									<%@ include file="/html/portlet/layouts_admin/layout/layout_templates_list.jspf" %>
								</div>
							</aui:nav-item>
						</c:if>

						<%
						List<LayoutPrototype> layoutPrototypes = LayoutPrototypeServiceUtil.search(company.getCompanyId(), Boolean.TRUE, null);

						for (LayoutPrototype layoutPrototype : layoutPrototypes) {
							String name = HtmlUtil.escape(layoutPrototype.getName(user.getLanguageId()));
						%>

							<aui:nav-item cssClass="lfr-page-template" data-search="<%= name %>">
								<div class="lfr-page-template-title toggler-header toggler-header-collapsed" data-prototype-id="<%= layoutPrototype.getLayoutPrototypeId() %>">
									<aui:input id='<%= "addLayoutSelectedPageTemplate" + layoutPrototype.getUuid() %>' label="<%= name %>" name="selectedPageTemplate" type="radio" />

									<div class="lfr-page-template-description">
										<small><%= HtmlUtil.escape(layoutPrototype.getDescription()) %></small>
									</div>
								</div>

								<div class="lfr-page-template-options toggler-content toggler-content-collapsed">
									<aui:input id='<%= "addLayoutLayoutPrototypeLinkEnabled" + layoutPrototype.getUuid() %>' label="automatically-apply-changes-done-to-the-page-template" name="layoutPrototypeLinkEnabled" type="checkbox" />
								</div>
							</aui:nav-item>

						<%
						}
						%>

						<%
						LayoutLister layoutLister = new LayoutLister();

						LayoutView layoutView = layoutLister.getLayoutView(scopeGroupId, privateLayout, rootNodeName, locale);

						liferayPortletRequest.setAttribute(WebKeys.LAYOUT_LISTER_LIST, layoutView.getList());

						for (int i = 0; i < PropsValues.LAYOUT_TYPES.length; i++) {
							if (PropsValues.LAYOUT_TYPES[i].equals("portlet")) {
								continue;
							}
						%>

							<aui:nav-item cssClass="lfr-page-template" data-search='<%= LanguageUtil.get(pageContext, "layout.types." + PropsValues.LAYOUT_TYPES[i]) %>'>
								<div class="lfr-page-template-title toggler-header toggler-header-collapsed" data-type="<%= PropsValues.LAYOUT_TYPES[i] %>">
									<aui:input id='<%= "addLayoutSelectedPageTemplate" + PropsValues.LAYOUT_TYPES[i] %>' label='<%= "layout.types." + PropsValues.LAYOUT_TYPES[i] %>' name="selectedPageTemplate" type="radio" />

									<div class="lfr-page-template-description">
										<small><%= LanguageUtil.get(pageContext, "layout.types." + PropsValues.LAYOUT_TYPES[i] + ".description" ) %></small>
									</div>
								</div>

								<div class="lfr-page-template-options toggler-content toggler-content-collapsed">
									<liferay-util:include page="<%= StrutsUtil.TEXT_HTML_DIR + PortalUtil.getLayoutEditPage(PropsValues.LAYOUT_TYPES[i]) %>" />
								</div>
							</aui:nav-item>

						<%
						}
						%>

						<c:if test='<%= ArrayUtil.contains(PropsValues.LAYOUT_TYPES, "portlet") %>'>
							<aui:nav-item cssClass="lfr-page-template" data-search="portlet">
								<div class="lfr-page-template-title toggler-header toggler-header-collapsed" data-type="portlet">
									<aui:input id="addLayoutSelectedPageTemplateCopyOfPage" label="copy-of-a-page" name="selectedPageTemplate" type="radio" />

									<div class="lfr-page-template-description">
										<small><%= LanguageUtil.get(pageContext, "copy-of-a-page-description" ) %></small>
									</div>
								</div>

								<div class="lfr-page-template-options toggler-content toggler-content-collapsed">
									<liferay-util:include page="/html/portal/layout/edit/portlet.jsp" />
								</div>
							</aui:nav-item>
						</c:if>
					</aui:nav>
				</aui:fieldset>
			</div>
		<div>
	</aui:fieldset>

	<aui:button-row cssClass="lfr-add-page-toolbar">
		<div class="pull-right">
			<aui:button id="addLayoutSubmit" type="submit" value="add-page" />

			<aui:button id="addLayoutCancel" name="cancelAddOperation" value="cancel" />
		</div>
	</aui:button-row>
</aui:form>

<c:if test="<%= portletName.equals(PortletKeys.DOCKBAR) %>">

	<%
	Layout addedLayout = (Layout)SessionMessages.get(liferayPortletRequest, portletDisplay.getId() + "pageAdded");
	%>

	<c:if test="<%= addedLayout != null && !addedLayout.isHidden() %>">

		<%
		NavItem navItem = new NavItem(request, addedLayout, null);
		%>

		<aui:script use="aui-base">
			Liferay.fire('dockbaraddpage:addPage',
				{
					data: {
						layoutId: <%= addedLayout.getLayoutId() %>,
						parentLayoutId: <%= addedLayout.getParentLayoutId() %>,
						title: A.Lang.String.escapeHTML('<%= navItem.getName() %>'),
						url: '<%= navItem.getURL() %>'
					}
				}
			);
		</aui:script>
	</c:if>
</c:if>

<aui:script use="liferay-dockbar-add-page">
	new Liferay.Dockbar.AddPage(
		{
			createPageMessage: '<%= LanguageUtil.get(pageContext, "loading") %>',
			focusItem: A.one('#<portlet:namespace />addLayoutName'),
			inputNode: A.one('#<portlet:namespace />addLayoutSearchTemplates'),
			namespace: '<portlet:namespace />',
			nodeList: A.one('#<portlet:namespace />templateList'),
			nodeSelector: '.lfr-page-template',
			parentLayoutId: <%= parentLayoutId %>,
			refresh: <%= layout.isTypeControlPanel() %>,
			selected: !A.one('#<portlet:namespace />addPageFm').ancestor().hasClass('hide'),
			toggleOnCancel: <%= portletName.equals(PortletKeys.DOCKBAR) %>
		}
	);
</aui:script>